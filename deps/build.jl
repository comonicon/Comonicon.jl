using Pkg
PROJECT = joinpath(dirname(dirname(@__FILE__)), "example", "Ion")
Pkg.activate(PROJECT)

using Comonicon, Ion
Comonicon.install(Ion, "ion"; compile=:min)
