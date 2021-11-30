function print_builder_help(io::IO = stdout)
    println(io, "Comonicon - Builder CLI.")
    println(io)
    print(io, "Builder CLI for Comonicon Applications. If not sepcified, run the command")
    printstyled(io, " install "; color = :cyan); print(io, "by default.")
    println(io)
    println(io)
    printstyled(io, "USAGE\n\n"; bold = true)
    printstyled(io, " "^4, "julia --project deps/build.jl [command]\n\n"; color = :cyan)
    printstyled(io, "COMMAND\n\n"; bold = true)

    printstyled(io, " "^4, "install"; color = :light_blue, bold = true)
    println(io, " "^21, "install the CLI locally.\n")

    printstyled(io, " "^4, "app"; color = :light_blue, bold = true)
    printstyled(io, " [tarball]"; color = :blue)
    println(io, " "^15, "build the application, optionally make a tarball.\n")

    printstyled(io, " "^4, "sysimg"; color = :light_blue, bold = true)
    printstyled(io, " [tarball]"; color = :blue)
    println(io, " "^12, "build the system image, optionally make a tarball.\n")

    printstyled(io, " "^4, "tarball"; color = :light_blue, bold = true)
    println(io, " "^21, "build application and system image then make tarballs")
    println(io, " "^32, "for them.\n")

    printstyled(io, "EXAMPLE\n\n"; bold = true)
    printstyled(io, " "^4, "julia --project deps/build.jl install\n\n"; color = :cyan)
    println(
        io,
        " "^4,
        "install the CLI to ~/.julia/bin.\n\n",
    )
    printstyled(io, " "^4, "julia --project deps/build.jl sysimg\n\n"; color = :cyan)
    println(
        io,
        " "^4,
        "build the system image in the path defined by Comonicon.toml or in deps by default.\n\n",
    )
    printstyled(io, " "^4, "julia --project deps/build.jl sysimg tarball\n\n"; color = :cyan)
    println(io, " "^4, "build the system image then make a tarball on this system image.\n\n")
    printstyled(io, " "^4, "julia --project deps/build.jl app tarball\n\n"; color = :cyan)
    println(
        io,
        " "^4,
        "build the application based on Comonicon.toml and make a tarball from it.\n\n",
    )
end

function command_main(m::Module; kw...)::Cint
    options = Options.read_options(m; kw...)
    command_main(m, options)
    return 0
end

function command_main(m::Module, options::Options.Comonicon)
    if "-h" in ARGS || "--help" in ARGS || "help" in ARGS
        print_builder_help()
        return
    elseif isempty(ARGS) || (first(ARGS) == "install" && length(ARGS) == 1)
        if options.install.quiet
            logger = NullLogger()
        else
            logger = ConsoleLogger()
        end

        with_logger(logger) do
            install(m, options)
        end
        return
    elseif first(ARGS) == "sysimg" && !isnothing(options.sysimg)
        build_sysimg(m, options)
        if length(ARGS) == 2 && ARGS[2] == "tarball"
            build_sysimg_tarball(m, options)
        end
        return
    elseif first(ARGS) == "app" && !isnothing(options.application)
        build_application(m, options)
        if length(ARGS) == 2 && ARGS[2] == "tarball"
            build_application_tarball(m, options)    
            return
        end
    elseif first(ARGS) == "tarball" && (!isnothing(options.sysimg) || !isnothing(options.application))
        if length(ARGS) == 1
            build_sysimg(m, options)
            build_application(m, options)
            build_sysimg_tarball(m, options) == 0 || return
            build_application_tarball(m, options) == 0 || return
            return
        end
    end

    # otherwise print help
    printstyled("unknown command: "; bold=true, color=:red)
    printstyled(join(ARGS, " "); color=:red)
    println()
    println()
    print_builder_help()
    return
end
