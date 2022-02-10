function build_sysimg(
    m::Module,
    options::Configs.Comonicon;
    incremental = options.sysimg.incremental,
    cpu_target = options.sysimg.cpu_target,
    filter_stdlibs = options.sysimg.filter_stdlibs,
)

    precompile_execution_file = String[pkgdir(m, x) for x in options.sysimg.precompile.execution_file]
    precompile_statements_file =
        String[pkgdir(m, x) for x in options.sysimg.precompile.statements_file]

    create_sysimage(
        [nameof(m)];
        sysimage_path = sysimg_dylib(m, options),
        project = create_command_env(m),
        incremental,
        cpu_target,
        filter_stdlibs,
        precompile_execution_file,
        precompile_statements_file,
    )
    return
end

"""
    create_command_env(m::Module, envpath::String=mktempdir(); test_deps=true)

Create an environment to execute the CLI command.

# Arguments

- `m`: the CLI module.
- `envpath`: the generated environment path.

# Keyword Arguments

- `test_deps`: include test deps or not.
"""
function create_command_env(m::Module, envpath::String = mktempdir(); test_deps::Bool = true)
    project = Pkg.Types.projectfile_path(pkgdir(m))
    ctx = Pkg.Types.Context(env = Pkg.Types.EnvCache(project))
    cmd_project = Pkg.Types.Project()
    merge!(cmd_project.deps, ctx.env.project.deps)
    merge!(cmd_project.compat, ctx.env.project.compat)
    # add the package to dependencies
    cmd_project.deps[ctx.env.project.name] = ctx.env.project.uuid

    if test_deps
        merge!(cmd_project.deps, ctx.env.project.extras)
        test_project = Pkg.Types.projectfile_path(pkgdir(m, "test"))
        if !isnothing(test_project) # add test deps if has it
            test_env = Pkg.Types.EnvCache(test_project)
            merge!(cmd_project.deps, test_env.project.deps)
            merge!(cmd_project.compat, test_env.project.compat)
        end
    end

    cmd_project_path = Pkg.Types.projectfile_path(envpath)
    cmd_manifest_path = Pkg.Types.manifestfile_path(envpath)
    Pkg.Types.write_project(cmd_project, cmd_project_path)

    # update Manifest from project
    if v"1.6" ≤ VERSION < v"1.7-"
        pkg_manifest = Pkg.Operations.abspath!(ctx, ctx.env.manifest)
    elseif v"1.7" ≤ VERSION < v"1.8-"
        pkg_manifest = Pkg.Operations.abspath!(ctx.env, ctx.env.manifest)
    else
        error("unsupported Julia version: $VERSION")
    end
    # TODO: merge test into the package manifest
    # how does TestENV do it? it's a bit unclear
    # cmd_env = Pkg.Types.EnvCache(cmd_project_path)
    # cmd_manifest = cmd_env.manifest
    # for (name, uuid) in ctx.env.project.deps
    #     entry = get(pkg_manifest, uuid, nothing)
    #     if !isnothing(entry) && Pkg.Operations.isfixed(entry)
    #         subgraph = Pkg.Operations.prune_manifest(pkg_manifest, [uuid])
    #         for (uuid, entry) in subgraph
    #             if haskey(cmd_manifest, uuid)
    #                 @show cmd_manifest[uuid]
    #                 Pkg.Types.pkgerror("can not merge projects")
    #             end
    #             cmd_manifest[uuid] = entry
    #         end
    #     end
    # end

    Pkg.Types.write_manifest(pkg_manifest, cmd_manifest_path)
    current_project = Base.current_project()
    Pkg.activate(envpath)
    Pkg.develop(Pkg.PackageSpec(path = pkgdir(m)))
    Pkg.update()
    # NOTE: in global env, current_project is nothing
    isnothing(current_project) || Pkg.activate(current_project)
    return envpath
end

function build_sysimg_tarball(m::Module, options::Configs.Comonicon)
    dylib = sysimg_dylib(m, options)
    tarball = tarball_name(m, options.name, "sysimg")

    tmp_dir = mktempdir()
    cd(tmp_dir) do
        mkdir("sysimg")
        cp(dylib, joinpath("sysimg", basename(dylib)))
        run(`tar -czvf $tarball sysimg`)
    end
    mv(joinpath(tmp_dir, tarball), joinpath(pwd(), tarball))
    return
end

function download_sysimg(m::Module, options::Configs.Comonicon)
    url = sysimg_url(m, options)
    isnothing(url) && error("$m does not have a host")
    tarball = download(url)
    dylib = sysimg_dylib(m, options)
    Pkg.unpack(tarball, dylib)
    # NOTE: sysimg won't be shared, so we can just remove it
    isfile(tarball) && rm(tarball)
    return
end

function sysimg_url(m::Module, options::Configs.Comonicon)
    isnothing(options.download) && return
    host = options.download.host
    if host == "github.com"
        url =
            "https://github.com/" *
            options.download.user *
            "/" *
            options.download.repo *
            "/releases/download/"
    else
        error("host $host is not supported, please open an issue at $COMONICON_URL")
    end

    tarball = tarball_name(mod, name, "sysimg")
    url *= "v$(get_version(mod))/$tarball"
    return url
end

function sysimg_dylib(m::Module, options::Configs.Comonicon)
    dylib_name = "lib$(options.name).$(Libdl.dlext)"
    sysimg_dir = get_scratch!(m, "sysimg")
    return joinpath(sysimg_dir, dylib_name)
end
