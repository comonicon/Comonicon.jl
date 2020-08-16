module BuildTools

export install, build

using Logging
using PackageCompiler
using Pkg
using Pkg.TOML
using Pkg.PlatformEngines
using ..Comonicon
using ..Comonicon.Parse
using ..Comonicon.CodeGen
using ..Comonicon.PATH
using ..Comonicon.Types
using ..Comonicon.Tools

const COMONICON_URL = "https://github.com/Roger-luo/Comonicon.jl"
# Comonicon.toml
# name = "ion"

# [install]
# bin = "~/.julia/bin"
# completion=true
# quiet=false
# compile="min"
# optimize=2

# [sysimg]
# path="deps/lib"
# incremental=false
# filter_stdlibs=true
# cpu_target="native"

# [download]
# host="github.com"
# user="Roger-luo"

const DEFAULT_INSTALL_CONFIG = Dict(
    "bin" => PATH.default_julia_bin(),
    "completion" => true,
    "quiet" => false,
    "compile" => nothing,
    "optimize" => 2,
)

const DEFAULT_SYSIMG_CONFIG = Dict(
    "path" => "deps/lib",
    "incremental" => true,
    "filter_stdlibs" => false,
    "cpu_target" => "native",
)

const COMONICON_TOML = ["Comonicon.toml", "JuliaComonicon.toml"]

function build(mod, sysimg = true; incremental = true, filter_stdlibs = false, kwargs...)
    configs = read_configs(mod; incremental = incremental, filter_stdlibs = filter_stdlibs, kwargs...)

    validate_toml(configs)
    configs = merge_defaults(mod, configs)

    if sysimg && !haskey(configs, "sysimg")
        configs["sysimg"] = DEFAULT_SYSIMG_CONFIG
    elseif !sysimg
        delete!(configs, "sysimg")
    end
    # do not download in manual mode
    delete!(configs, "download")
    return install(mod, configs)
end

function install(mod; kwargs...)
    configs = read_configs(mod; kwargs...)
    configs = merge_defaults(mod, configs)
    validate_toml(configs)
    return install(mod, configs)
end

function read_configs(mod; kwargs...)
    configs = read_toml(mod)
    for (k, v) in kwargs
        if k == :name
            configs["name"] = v
        end

        if k in [:bin, :completion, :quiet, :compile, :optimize]
            install_configs = get!(configs, "install", Dict{String,Any}())
            install_configs[string(k)] = v
        end

        if k in [:path, :incremental, :filter_stdlibs, :cpu_target]
            sysimg_configs = get!(configs, "sysimg", Dict{String,Any}())
            sysimg_configs[string(k)] = v
        end

        if k in [:host, :repo, :user]
            download_config = get!(configs, "download", Dict{String,Any}())
            download_config[string(k)] = v
        end
    end
    return configs
end

function read_toml(mod)
    path = nothing
    for file in COMONICON_TOML
        _path = PATH.project(mod, file)
        if ispath(_path)
            path = _path
            break
        end
    end

    path === nothing && return Dict()
    configs = TOML.parsefile(path)
    return configs
end

function merge_defaults(mod, configs)
    if haskey(configs, "sysimg")
        configs["sysimg"] = merge(DEFAULT_SYSIMG_CONFIG, configs["sysimg"])
    end

    configs["install"] = merge(DEFAULT_INSTALL_CONFIG, configs["install"])
    if !haskey(configs, "name")
        configs["name"] = Parse.default_name(mod)
    end
    return configs
end

function validate_toml(configs)
    _check(configs["install"], "compile") do x
        x in [nothing, "min", "no", "all", "yes"]
    end

    for key in ["completion", "quiet"]
        _check(configs["install"], key) do x
            x isa Bool
        end
    end

    _check(configs["install"], "optimize") do x
        x isa Int
    end

    haskey(configs, "sysimg") || return

    for key in ["incremental", "filter_stdlibs"]
        _check(configs["sysimg"], key) do x
            x isa Bool
        end
    end

    haskey(configs, "download") || return

    for key in ["host", "user", "repo"]
        _check(configs["download"], key) do x
            x isa String
        end
    end

    return
end

function _check(f, configs, key)
    haskey(configs, key) || error("missing key $key in Comonicon.toml or kwargs")
    got = configs[key]
    f(got) || error("invalid value $got for field \"$key\" in Comonicon.toml or kwargs")
    return
end

function install(mod::Module, configs::Dict)
    if configs["install"]["quiet"]
        logger = NullLogger()
    else
        logger = ConsoleLogger()
    end

    with_logger(logger) do
        if haskey(configs, "sysimg")
            install_sysimg(mod, configs)
        end

        # if the system image is required by the developer,
        # when system image installation
        # errors, the CLI will not be installed.
        # User will need to use mod.build([sysimg=false]) to install it
        # manually, with an option to install without system image
        # or build it locally.

        # do not install script while building tarball
        if !("sysimg" in ARGS)
            install_script(mod, configs)
        end
    end
    return
end

function install_script(mod::Module, configs::Dict)
    if haskey(configs, "sysimg") && isfile(sysimage_path(mod, configs))
        sysimg_path = sysimage_path(mod, configs)
    else
        sysimg_path = nothing
    end

    install_configs = configs["install"]
    name = configs["name"]
    bin = install_configs["bin"]

    shadow = joinpath(bin, name * ".jl")
    if install_configs["compile"] === nothing
        compile = nothing
    else
        compile = Symbol(install_configs["compile"])
    end

    env = create_environment(mod, name)

    shell_script = cmd_script(
        mod,
        shadow;
        sysimg = sysimg_path,
        project = env,
        compile = compile,
        optimize = install_configs["optimize"],
    )

    file = joinpath(bin, name)

    if !ispath(bin)
        @info "cannot find Julia bin folder creating .julia/bin"
        mkpath(bin)
    end

    # generate contents
    @info "generating $shadow"
    open(shadow, "w+") do f
        println(f, "#= generated by Comonicon for $name =# using $mod; $mod.command_main()")
    end

    @info "generating $file"
    open(file, "w+") do f
        println(f, shell_script)
    end

    if install_configs["completion"]
        install_completion(mod, joinpath(dirname(bin), "completions"))
    end

    chmod(file, 0o777)
    return
end

function install_sysimg(mod::Module, configs::Dict)
    # if sysimg will be downloaded on user side
    # when we build the sysimg, a tarball should
    # be generated.
    if haskey(configs, "download")
        # we create a system image tarball
        # via an argument sysimg
        if "sysimg" in ARGS
            build_sysimg(mod, configs)
            create_tarball(mod, configs["name"])
        else
            download_sysimg(mod, configs)
        end
    else # manually triggered
        build_sysimg(mod, configs)
        if "tarball" in ARGS
            create_tarball(mod, configs["name"])
        end
    end
    return
end

function sysimage_path(mod, configs)
    return PATH.project(mod, configs["sysimg"]["path"], PATH.sysimg(configs["name"]))
end

function download_sysimg(mod::Module, configs::Dict)
    sysimg_configs = configs["sysimg"]
    name = configs["name"]
    os = osname()
    tarball_name = "$name-$(VERSION)-$os-$(Sys.ARCH).tar.gz"

    url = sysimg_url(mod, configs)
    tarball = joinpath(PATH.project(mod, "deps", tarball_name))
    PlatformEngines.probe_platform_engines!()

    try
        download(url, tarball)
        unpack(tarball, PATH.project(mod, "deps"))
    catch e
        error("fail to download $url, consider build the system image locally via $mod.comonicon_build()")
    end

    if ispath(tarball)
        rm(tarball)
    end
    return
end

function sysimg_url(mod, configs)
    name = configs["name"]
    host = configs["download"]["host"]
    if host == "github.com"
        url =
            "https://github.com/" *
            configs["download"]["user"] *
            "/" *
            configs["download"]["repo"] *
            "/releases/download/"
    else
        error("host $host is not supported, please open an issue at $COMONICON_URL")
    end

    tarball = tarball_name(name)
    url *= "v$(Comonicon.get_version(mod))/$tarball"
    return url
end

function build_sysimg(mod::Module, configs::Dict)
    sysimg_configs = configs["sysimg"]
    lib_path = PATH.project(mod, sysimg_configs["path"])
    if !ispath(lib_path)
        @info "creating library path: $lib_path"
        mkpath(lib_path)
    end

    # install precompile script
    precompile_jl = PATH.project(mod, "deps", "precompile.jl")
    @info "generating precompile execution file: $precompile_jl"
    open(precompile_jl, "w+") do f
        print(f, precompile_script(mod))
    end

    project = PATH.project(mod)
    incremental = sysimg_configs["incremental"]
    filter_stdlibs = sysimg_configs["filter_stdlibs"]
    cpu_target = sysimg_configs["cpu_target"]
    image_path = sysimage_path(mod, configs)

    @info "compile under project: $project"
    @info "incremental: $incremental"
    @info "filter stdlibs: $filter_stdlibs"
    @info "system image path: $image_path"

    create_sysimage(
        nameof(mod);
        sysimage_path = image_path,
        incremental = incremental,
        project = project,
        precompile_execution_file = [precompile_jl, PATH.project(mod, "test", "runtests.jl")],
        cpu_target = cpu_target,
        filter_stdlibs = filter_stdlibs,
    )

    return
end

function create_tarball(mod::Module, name)
    version = get_version(mod)
    tarball = tarball_name(name)
    @info "creating tarball $tarball"
    cd(PATH.project(mod, "deps")) do
        run(`tar -czvf $tarball lib`)
    end
    return
end

function tarball_name(name)
    return "$name-$VERSION-$(osname())-$(Sys.ARCH).tar.gz"
end

"""
    osname()

Return the name of OS, will be used in building tarball.
"""
function osname()
    return Sys.isapple() ? "darwin" :
           Sys.islinux() ? "linux" :
           error("unsupported OS, please open an issue to request support at $COMONICON_URL")
end

"""
create a dedicated shared environment for the command
"""
function create_environment(mod::Module, name)
    Pkg.activate(name; shared=true)
    Pkg.add(PackageSpec(path=PATH.project(mod)))
    path = Base.active_project()
    Pkg.activate()
    return path
end

"""
    cmd_script(mod, shadow; kwargs...)

Generates a shell script that can be use as the entry of
`mod.command_main`.

# Arguments

- `mod`: a module that contains the commands and the entry.
- `shadow`: location of a Julia script that calls the actual `mod.command_main`.

# Keywords

- `exename`: The julia executable name, default is [`PATH.default_exename`](@ref).
- `sysimg`: System image to use, default is `nothing`.
- `project`: the project path of the CLI.
- `compile`: julia compile level, can be [:yes, :no, :all, :min]
- `optimize`: julia optimization level, default is 2.
"""
function cmd_script(
    mod::Module,
    shadow::String;
    project::String = PATH.project(mod),
    exename::String = PATH.default_exename(),
    sysimg = nothing,
    compile = nothing,
    optimize = 2,
)

    head = "#!/bin/sh\n"
    if (project !== nothing) && ispath(project)
        head *= "JULIA_PROJECT=$project "
    end
    head *= exename
    script = String[head]

    if sysimg !== nothing
        push!(script, "-J$sysimg")
    end

    if compile in [:yes, :no, :all, :min]
        push!(script, "--compile=$compile")
    end

    push!(script, "-O$optimize")
    push!(script, "-- $shadow \$@")

    return join(script, " \\\n    ")
end

"""
    precompile_script(mod)

Generates a script to execute as `precompile_execution_file` for all the commands.
"""
function precompile_script(mod::Module)
    script = "using $mod;\n$mod.command_main([\"-h\"]);\n"

    if isdefined(mod, :CASTED_COMMANDS)
        for (name, cmd) in mod.CASTED_COMMANDS
            if name != "main" # skip main command
                script *= "$mod.command_main([$(precompile_script(mod, cmd))]);\n"
            end
        end
    end
    return script
end

function precompile_script(mod::Module, cmd::EntryCommand)
    return precompile_script(mod, cmd.root)
end

function precompile_script(mod::Module, cmd::LeafCommand)
    return "\"$(cmd_name(cmd))\", \"-h\""
end

function precompile_script(mod::Module, cmd::NodeCommand)
    return join(map(x -> "\"$(cmd_name(cmd))\", " * precompile_script(mod, x), cmd.subcmds))
end

Base.write(x::EntryCommand) = write(cachefile(), x)

"""
    write([io], cmd::EntryCommand)

Write the generated CLI script into a Julia script file. Default is the [`cachefile`](@ref).
"""
function Base.write(io::IO, x::EntryCommand)
    println(io, "#= generated by Comonicon =#")
    println(io, prettify(codegen(x)))
    println(io, "command_main()")
end

"""
    detect_shell()

Detect shell type via `SHELL` environment variable.
"""
function detect_shell()
    haskey(ENV, "SHELL") || error("cannot find available shell command")
    return basename(ENV["SHELL"])
end

"""
    install_completion(m::Module[, path::String=PATH.default_julia_fpath()])

Install completion script at `path`. Default path is [`PATH.default_julia_fpath()`](@ref).
"""
function install_completion(m::Module, path::String = PATH.default_julia_fpath())
    isdefined(m, :CASTED_COMMANDS) || error("cannot find Comonicon CLI entry")
    haskey(m.CASTED_COMMANDS, "main") || error("cannot find Comonicon CLI entry")

    main = m.CASTED_COMMANDS["main"]
    shell = detect_shell()
    shell === nothing && return

    if shell == "zsh"
        ctx = CodeGen.ZSHCompletionCtx()
    else
        @warn "$shell completion is not supported yet"
        return
    end

    script = CodeGen.codegen(ctx, main)

    if !ispath(path)
        mkpath(path)
    end

    write(joinpath(path, "_" * cmd_name(main)), script)
    return
end

function contain_comonicon_path(rcfile, env = ENV)
    if !haskey(env, "PATH")
        _contain_path(rcfile) && return true
        return false
    end

    for each in split(env["PATH"], ":")
        each == PATH.default_julia_bin() && return true
    end
    return false
end

function contain_comonicon_fpath(rcfile, env = ENV)
    if !haskey(env, "FPATH")
        _contain_fpath(rcfile) && return true
        return false
    end

    for each in split(env["FPATH"], ":")
        each == PATH.default_julia_fpath() && return true
    end
    return false
end

function _contain_path(rcfile)
    for line in readlines(rcfile)
        if strip(line) == "export PATH=\"\$HOME/.julia/bin:\$PATH\"" ||
           strip(line) == "export PATH=\"$(PATH.default_julia_bin()):\$PATH\""
            return true
        end
    end
    return false
end

function _contain_fpath(rcfile)
    for line in readlines(rcfile)
        if strip(line) == "export FPATH=\$HOME/.julia/completions:\$FPATH" ||
           strip(line) == "export FPATH=\"$(PATH.default_julia_fpath()):\$FPATH\""
            return true
        end
    end
    return false
end

function install_env_path(; yes::Bool = false)
    shell = detect_shell()

    config_file = ""
    if shell == "zsh"
        config_file = joinpath((haskey(ENV, "ZDOTDIR") ? ENV["ZDOTDIR"] : homedir()), ".zshrc")
    elseif shell == "bash"
        config_file = joinpath(homedir(), ".bashrc")
    else
        @warn "auto installation for $shell is not supported, please open an issue under Comonicon.jl"
    end

    write_path(joinpath(homedir(), config_file), yes)
end

"""
    write_path(rcfile[, yes=false])

Write `PATH` and `FPATH` to current shell's rc files (.zshrc, .bashrc)
if they do not exists.
"""
function write_path(rcfile, yes::Bool = false, env = ENV)
    isempty(rcfile) && return

    script = []
    msg = "cannot detect ~/.julia/bin in PATH, do you want to add it in PATH?"

    if !contain_comonicon_path(rcfile, env) && Tools.prompt(msg, yes)
        push!(
            script,
            """
# generated by Comonicon
# Julia bin PATH
export PATH="$(PATH.default_julia_bin()):\$PATH"
""",
        )
        @info "adding PATH to $rcfile"
    end

    msg = "cannot detect ~/.julia/completions in FPATH, do you want to add it in FPATH?"
    if !contain_comonicon_fpath(rcfile, env) && Tools.prompt(msg, yes)
        push!(
            script,
            """
# generated by Comonicon
# Julia autocompletion PATH
export FPATH="$(PATH.default_julia_fpath()):\$FPATH"
""",
        )
        @info "adding FPATH to $rcfile"
    end

    # exit if nothing to add
    isempty(script) && return
    # NOTE: we don't create the file if not exists
    open(rcfile, "a") do io
        write(io, "\n" * join(script, "\n"))
    end
    @info "open a new terminal, or source $rcfile to enable the new PATH."
    return
end


end # BuildTools
