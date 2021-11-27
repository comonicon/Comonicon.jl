root = dirname(@__DIR__)
lib_dir = joinpath(root, "lib")
example_dir = joinpath(root, "example")

# activate root
using Pkg; Pkg.activate(root)

# collect packages
pkgs = []
if isempty(ARGS) # test all by default
    for each_lib in readdir(lib_dir)
        path = joinpath(lib_dir, each_lib)
        isdir(path) && push!(pkgs, PackageSpec(;path))
    end

    for each_example in readdir(example_dir)
        path = joinpath(example_dir, each_example)
        isdir(path) && push!(pkgs, PackageSpec(;path))
    end
else
    for each in ARGS
        if each == "Comonicon"
            push!(pkgs, PackageSpec(path=root))
        else
            push!(pkgs, PackageSpec(path=joinpath(root, each)))
        end
    end
end

using TestEnv
TestEnv.activate() do
    # always dev root package
    Pkg.develop(PackageSpec(path=root))
    foreach(Pkg.develop, pkgs)
    Pkg.status()
    # load mocks
    include("mock.jl")
    # start test
    for pkg in pkgs
        include(joinpath(pkg.path, "test", "runtests.jl"))
    end
end
