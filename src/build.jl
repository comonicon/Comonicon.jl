
const DEFAULT_SYSIMG = joinpath(dirname(pathof(Comonicon)), "..", "deps", "lib", "libcomonicon.$(Libdl.dlext)")

default_exename() = joinpath(Sys.BINDIR, Base.julia_exename())
default_project(mod) = dirname(dirname(pathof(mod)))

function cmd_script(mod; exename=default_exename(), project=default_project(mod), sysimg=DEFAULT_SYSIMG, compile=nothing, optimize=2)
    shebang = "#!$exename -J$sysimg --project=$project"
    if compile in [:yes, :no, :all, :min]
        shebang *= " --compile=$compile"
    end

    shebang *= " -O$optimize"
    return """$shebang
    using $mod; $mod.command_main()
    """
end

function install(mod::Module, name;
        bin=joinpath(first(DEPOT_PATH), "bin"),
        exename=default_exename(),
        project=default_project(mod),
        sysimg=DEFAULT_SYSIMG,
        compile=nothing,
        optimize=2)

    script = cmd_script(mod; exename=exename, project=project, sysimg=sysimg, compile=compile, optimize=optimize)
    file = joinpath(bin, name)

    if !ispath(bin)
        mkpath(bin)
    end

    open(file, "w+") do f
        println(f, script)
    end

    chmod(file, 0o777)
    return
end

function Base.write(io::IO, x::EntryCommand; exec=false)
    println(io, "#= generated by Comonicon =#")
    println(io, rm_lineinfo(codegen(x)))
    if exec
        println(io, "command_main()")
    end
end
