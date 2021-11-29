using Pkg
using TestEnv
using Comonicon

"""
run Comonicon tests.

# Args

- `testset`: which testset to run, can be `all`, `Comonicon`, `lib`, `example`.

# Flags

- `--coverage`: enable code coverage tracking.
"""
@main function command(testset::String="all"; coverage::Bool=false)
    root = dirname(@__DIR__)
    lib_dir = joinpath(root, "lib")
    example_dir = joinpath(root, "example")
    # activate root
    Pkg.activate(root)
    comonicon_jl = PackageSpec(path=root)
    
    # collect packages
    lib_pkgs = []
    lib_names = String[]
    example_pkgs = []
    example_names = String[]

    # collect libraries
    for each_lib in readdir(lib_dir)
        path = joinpath(lib_dir, each_lib)
        isdir(path) || continue
        push!(lib_pkgs, PackageSpec(;path))
        push!(lib_names, each_lib)
    end
    
    # collect examples
    for each_example in readdir(example_dir)
        path = joinpath(example_dir, each_example)
        isdir(path) || continue
        # we need to generate Manifest.toml for examples
        # to build sysimg and app
        package = PackageSpec(;path)
        Pkg.activate(path)
        Pkg.develop(comonicon_jl)
        push!(example_pkgs, package)
        push!(example_names, each_example)
    end

    TestEnv.activate() do
        foreach(Pkg.develop, lib_pkgs)
        foreach(Pkg.develop, example_pkgs)
        Pkg.status()
        # start test
        if testset == "all"
            Pkg.test("Comonicon"; coverage)
            Pkg.test(lib_names; coverage)
            Pkg.test(example_names; coverage)
        elseif testset == "Comonicon"
            Pkg.test("Comonicon"; coverage)
        elseif testset == "example"
            Pkg.test(example_names; coverage)
        elseif testset == "lib"
            Pkg.test(lib_names; coverage)
        end
    end    
end
