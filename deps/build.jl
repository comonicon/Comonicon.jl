using Pkg
PROJECT = joinpath(dirname(dirname(@__FILE__)), "example", "Ion")
Pkg.activate(PROJECT)
Pkg.build("Ion")
