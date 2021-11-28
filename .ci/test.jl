root = dirname(@__DIR__)
lib_dir = joinpath(root, "lib")
example_dir = joinpath(root, "example")

# activate root
using Pkg; Pkg.activate(root)
comonicon_jl = PackageSpec(path=root)
# collect packages
pkgs = []


if isempty(ARGS) # test all by default
    for each_lib in readdir(lib_dir)
        path = joinpath(lib_dir, each_lib)
        isdir(path) && push!(pkgs, PackageSpec(;path))
    end

    for each_example in readdir(example_dir)
        path = joinpath(example_dir, each_example)
        isdir(path) || continue
        package = PackageSpec(;path)
        Pkg.activate(path)
        Pkg.develop(comonicon_jl)
        push!(pkgs, package)
    end
    Pkg.activate(root)
else
    for each in ARGS
        if each == "Comonicon"
            push!(pkgs, comonicon_jl)
        else
            path = joinpath(root, each)
            isdir(path) || continue
            package = PackageSpec(;path)
            Pkg.activate(path)
            Pkg.develop(comonicon_jl)
            push!(pkgs, package)
        end
    end
end

using TestEnv
TestEnv.activate() do
    # always dev root package
    Pkg.develop(PackageSpec(path=root))
    foreach(Pkg.develop, pkgs)
    Pkg.status()
    # start test
    Pkg.test(pkgs; coverage=true)
end
