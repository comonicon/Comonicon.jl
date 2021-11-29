using Pkg
using TestEnv
using Comonicon

@main function command(test_pkgs::String...; coverage::Bool=false)
    root = dirname(@__DIR__)
    lib_dir = joinpath(root, "lib")
    example_dir = joinpath(root, "example")
    # activate root
    Pkg.activate(root)
    comonicon_jl = PackageSpec(path=root)
    # collect packages
    pkgs = [comonicon_jl]
    names = String[]
    
    # collect libraries
    for each_lib in readdir(lib_dir)
        path = joinpath(lib_dir, each_lib)
        isdir(path) || continue
        push!(pkgs, PackageSpec(;path))
        push!(names, each_lib)
    end
    
    for each_example in readdir(example_dir)
        path = joinpath(example_dir, each_example)
        isdir(path) || continue
        # we need to generate Manifest.toml for examples
        # to build sysimg and app
        package = PackageSpec(;path)
        Pkg.activate(path)
        Pkg.develop(comonicon_jl)
        push!(pkgs, package)
        push!(names, each_example)
    end

    TestEnv.activate() do
        foreach(Pkg.develop, pkgs)
        Pkg.status()
        # start test
        @show test_pkgs
        if isempty(test_pkgs)
            Pkg.test(names; coverage)
        else
            Pkg.test(collect(test_pkgs); coverage)
        end
    end    
end
