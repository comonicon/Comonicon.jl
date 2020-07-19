using PackageCompiler
using Libdl

function project(xs...)
    joinpath(dirname(@__FILE__), "..", xs...)
end

if !ispath(project("deps", "lib"))
    mkpath(project("deps", "lib"))
end

create_sysimage([:Comonicon, :Test];
    sysimage_path=project("deps", "lib", "libcomonicon.$(Libdl.dlext)"),
    project=project(), precompile_execution_file=project("test", "runtests.jl")
)
