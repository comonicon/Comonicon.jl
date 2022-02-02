function build_application(m, options)
    isnothing(options.application) && return
    build_dir = application_build_dir(m, options)
    ispath(build_dir) || mkpath(build_dir)
    @info "application options: " options.application build_dir

    exec_file = String[pkgdir(m, x) for x in options.application.precompile.execution_file]
    stmt_file = String[pkgdir(m, x) for x in options.application.precompile.statements_file]

    create_app(
        pkgdir(m),
        build_dir;
        executables = [options.name => "julia_main"],
        precompile_execution_file = exec_file,
        precompile_statements_file = stmt_file,
        incremental = options.application.incremental,
        filter_stdlibs = options.application.filter_stdlibs,
        force = true,
        include_lazy_artifacts = options.application.include_lazy_artifacts,
        cpu_target = options.application.cpu_target,
        c_driver_program = options.application.c_driver_program,
    )

    # build completions
    build_application_completion(m, options)

    # bundle assets
    bundle_assets(m, options)
    return
end

function build_application_completion(m::Module, options::Configs.Comonicon)
    isempty(options.application.shell_completions) && return
    build_dir = application_build_dir(m, options)
    completion_dir = joinpath(build_dir, "completions")
    if !ispath(completion_dir)
        @info "creating path: $completion_dir"
        mkpath(completion_dir)
    end

    for sh in options.application.shell_completions
        script = completion_script(m, options, sh)
        write(joinpath(completion_dir, "$sh.completion"), script)
    end
    return
end

function bundle_assets(m::Module, options::Configs.Comonicon)
    isempty(options.application.assets) && return
    build_dir = application_build_dir(m, options)
    share_dir = joinpath(build_dir, "share")
    ispath(share_dir) || mkpath(share_dir)
    for asset in options.application.assets
        if isnothing(asset.package)
            dst = joinpath(build_dir, "share", asset.path)
        else
            dst = joinpath(build_dir, "share", asset.package, asset.path)
        end
        ispath(dirname(dst)) || mkpath(dirname(dst))
        cp(Configs.get_path(m, asset), dst; force = true, follow_symlinks = true)
    end
    return
end

function build_application_tarball(m, options)
    tarball = joinpath(pwd(), tarball_name(m, options.name, "application"))
    cd(options.application.path) do
        run(`tar -czvf $tarball $(options.name)`)
    end
end

function application_build_dir(m, options)
    return abspath(options.application.path, options.name)
end
