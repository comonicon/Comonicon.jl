module Configs

export read_options, has_comonicon_toml, @asset_str

using TOML
using Configurations
using PackageCompiler: DEFAULT_EMBEDDING_WRAPPER
using Pkg

struct Asset
    package::Union{Nothing,String}
    path::String
end

function Asset(s::String)
    parts = strip.(split(s, ":"))
    if length(parts) == 1
        Asset(nothing, parts[1])
    elseif length(parts) == 2
        Asset(parts[1], parts[2])
    else
        error("invalid syntax for asset string: $s")
    end
end

macro asset_str(s::String)
    return Asset(s)
end

function Base.show(io::IO, ::MIME"text/plain", x::Asset)
    print(io, "asset\"")
    if x.package !== nothing
        printstyled(io, x.package, ": "; color = :green)
    end
    printstyled(io, x.path, "\""; color = :cyan)
end

Base.convert(::Type{Asset}, s::String) = Asset(s)

function get_path(m::Module, x::Asset)
    isnothing(x.package) && return pkgdir(m, x.path)
    ctx = Pkg.Types.Context()
    haskey(ctx.env.project.deps, x.package) || error("asset $x not in current project dependencies")

    uuid = ctx.env.project.deps[x.package]
    pkgid = Base.PkgId(uuid, x.package)
    origin = get(Base.pkgorigins, pkgid, nothing)
    return joinpath(dirname(dirname(origin.path)), x.path)
end

"""
    Install

Installation configurations.

## Keywords

- `path`: installation path.
- `completion`: set to `true` to install shell auto-completion scripts.
- `quiet`: print logs or not, default is `false`.
- `compile`: julia compiler option for CLIs if not built as standalone application, default is "min".
- `optimize`: julia compiler option for CLIs if not built as standalone application, default is `2`.
"""
@option struct Install
    path::String = "~/.julia"
    completion::Bool = true
    quiet::Bool = false
    compile::String = "yes"
    optimize::Int = 2
    nthreads::Int = 1
end

"""
    Precompile

Precompilation files for `PackageCompiler`.

## Keywords

- `execution_file`: precompile execution file.
- `statements_file`: precompile statements file.
"""
@option struct Precompile
    execution_file::Vector{String} = String[]
    statements_file::Vector{String} = String[]
end

# See https://github.com/JuliaCI/julia-buildbot/blob/489ad6dee5f1e8f2ad341397dc15bb4fce436b26/master/inventory.py
function default_app_cpu_target()
    if Sys.ARCH === :i686
        return "pentium4;sandybridge,-xsaveopt,clone_all"
    elseif Sys.ARCH === :x86_64
        return "generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"
    elseif Sys.ARCH === :arm
        return "armv7-a;armv7-a,neon;armv7-a,neon,vfp4"
    elseif Sys.ARCH === :aarch64
        return "generic" # is this really the best here?
    elseif Sys.ARCH === :powerpc64le
        return "pwr8"
    else
        return "generic"
    end
end

"""
    SysImg

System image build configurations.

## Keywords

- `path`: system image path to generate into, default is "deps/lib".
- `incremental`: set to `true` to build incrementally, default is `true`.
- `filter_stdlibs`: set to `true` to filter out unused stdlibs, default is `false`.
- `cpu_target`: cpu target to build, default is `PackageCompiler.default_app_cpu_target()`.
- `precompile`: precompile configurations, see [`Precompile`](@ref), default is `Precompile()`.
"""
@option struct SysImg
    path::String = "deps"
    incremental::Bool = true
    filter_stdlibs::Bool = false
    cpu_target::String = default_app_cpu_target()
    precompile::Precompile = Precompile()
end

"""
    Download

Download information.

## Keywords

- `host`: where are the tarballs hosted, default is "github.com"
- `user`: required, user name on the host.
- `repo`: required, repo name on the host.

!!! note
    Currently this only supports github, and this is considered experimental.
"""
@option struct Download
    host::String = "github.com"
    user::String
    repo::String
end

"""
    Application

Application build configurations.

## Keywords

- `path`: application build path, default is "build".
- `incremental`: set to `true` to build incrementally, default is `true`.
- `filter_stdlibs`: set to `true` to filter out unused stdlibs, default is `false`.
- `cpu_target`: cpu target to build, default is `PackageCompiler.default_app_cpu_target()`.
- `precompile`: precompile configurations, see [`Precompile`](@ref), default is `Precompile()`.
- `c_driver_program`: driver program.
"""
@option struct Application
    path::String = "build"
    assets::Vector{Asset} = Asset[]
    incremental::Bool = false
    filter_stdlibs::Bool = true
    include_lazy_artifacts::Bool = true
    cpu_target::String = default_app_cpu_target()
    precompile::Precompile = Precompile()
    c_driver_program::String = String(DEFAULT_EMBEDDING_WRAPPER)
    shell_completions::Vector{String} = ["zsh"]
end

"""
    Command

Configs for Command execution.

# Keywords

- `color`: whether print with color in help page, default is `true`.
- `static`: whether genrate help info at compile time,
    the format won't be adaptive to displaysize anymore,
    if `true`, default is `true`.
- `dash`: whether parse `--` seperator, default is `true`.
- `plugin`: parse `<main CLI name>-<plugin>` for CLI plugin, default is `false`.
"""
@option struct Command
    color::Bool = true
    static::Bool = true
    dash::Bool = true
    plugin::Bool = false
end

"""
    Comonicon

Build configurations for Comonicon. One can set this option
via `Comonicon.toml` under the root path of a Julia
project directory and read in using [`read_configs`](@ref).

## Keywords

- `name`: required, the name of CLI file to install.
- `color`: whether print with color in help page.
- `static_displaysize`: whether format the display at compile time to reduce latency, default is `false`
- `install`: installation options, see also [`Install`](@ref).
- `sysimg`: system image build options, see also [`SysImg`](@ref).
- `download`: download options, see also [`Download`](@ref).
- `application`: application build options, see also [`Application`](@ref).
"""
@option struct Comonicon
    name::String

    command::Command = Command()
    install::Install = Install()
    sysimg::Maybe{SysImg} = nothing
    download::Union{Download,Nothing} = nothing
    application::Union{Application,Nothing} = nothing
end

function validate(options::Comonicon)
    if options.sysimg !== nothing
        isabspath(options.sysimg.path) && error("system image path must be project relative")
    end

    if options.application !== nothing
        isabspath(options.application.path) && error("application build path must project relative")
    end
    return
end

"""
    find_comonicon_toml(path::String, files=["Comonicon.toml", "JuliaComonicon.toml"])

Find `Comonicon.toml` or `JuliaComonicon.toml` in given path.
"""
function find_comonicon_toml(path::String, files = ["Comonicon.toml", "JuliaComonicon.toml"])
    # user input file path
    basename(path) in files && return path

    # user input dir path
    for file in files
        path = joinpath(path, file)
        if ispath(path)
            return path
        end
    end
    return
end

"""
    read_toml(path::String)

Read `Comonicon.toml` or `JuliaComonicon.toml` in given path.
"""
function read_toml(path::String)
    file = find_comonicon_toml(path)
    file === nothing && return Dict{String,Any}()
    return TOML.parsefile(file)
end

"""
    read_toml(mod::Module)

Read `Comonicon.toml` or `JuliaComonicon.toml` in given module's project path.
"""
function read_toml(mod::Module)
    path = pkgdir(mod)
    path === nothing && return Dict{String, Any}()
    return read_toml(path)
end

function has_comonicon_toml(m::Module)
    path = pkgdir(m)
    isnothing(path) && return false
    !isnothing(find_comonicon_toml(path))
end

"""
    read_options(comonicon; kwargs...)

Read in Comonicon build options. The argument `comonicon` can be:

- a module of a Comonicon CLI project.
- a path to a Comonicon CLI project that contains either `JuliaComonicon.toml` or `Comonicon.toml`.
- a path to a Comonicon CLI build configuration file named either `JuliaComonicon.toml` or `Comonicon.toml`.

In some cases, you might want to change the configuration written in the TOML file temporarily, e.g for writing
build tests etc. In this case, you can modify the configuration using corresponding keyword arguments.

keyword arguments of [`Application`](@ref) and [`SysImg`](@ref) are the same, thus keys like `filter_stdlibs`
are considered ambiguous in `read_options`, but you can specifiy them by specifiy the specific [`Application`](@ref)
or [`SysImg`](@ref) object, e.g

```julia
read_options(MyCLI; sysimg=SysImg(filter_stdlibs=false))
```

See also [`Comonicon`](@ref), [`Install`](@ref), [`SysImg`](@ref), [`Application`](@ref),
[`Download`](@ref), [`Precompile`](@ref).
"""
function read_options(m::Union{Module,String}; kwargs...)
    d = read_toml(m)
    if !haskey(d, "name")
        d["name"] = default_cmd_name(m)
    end

    options = from_dict(Comonicon, d; kwargs...)
    validate(options)
    return options
end

default_cmd_name(m::Module) = lowercase(string(nameof(m)))
default_cmd_name(m) = error("command name is not specified")

end
