using Pkg
using TestEnv
using Comonicon

function collect_lib()
    root = dirname(@__DIR__)
    lib_dir = joinpath(root, "lib")
    lib_pkgs = []
    lib_names = String[]
    # collect libraries
    for each_lib in readdir(lib_dir)
        path = joinpath(lib_dir, each_lib)
        isdir(path) || continue
        push!(lib_pkgs, PackageSpec(;path))
        push!(lib_names, each_lib)
    end
    return lib_pkgs, lib_names
end

function collect_example()
    root = dirname(@__DIR__)
    example_dir = joinpath(root, "example")
    example_pkgs = []
    example_names = String[]
    # collect examples
    for each_example in readdir(example_dir)
        path = joinpath(example_dir, each_example)
        isdir(path) || continue
        push!(example_pkgs, PackageSpec(;path))
        push!(example_names, each_example)
    end
    return example_pkgs, example_names
end

function generate_example_manifest(pkgs)
    # we need to generate Manifest.toml for examples
    # to build sysimg and app
    root = dirname(@__DIR__)
    comonicon_jl = PackageSpec(path=root)
    for pkg in pkgs
        Pkg.activate(pkg.path)
        Pkg.develop(comonicon_jl)
    end
    return
end

"""
develop package set at current activate environment.

# Args

- `set`: package set name, can be `Comonicon`, `lib`, `example`, `all`.
"""
@cast function dev(set::String="all")
    root = dirname(@__DIR__)
    if set == "Comonicon"
        Pkg.develop(PackageSpec(path=root))
    elseif set == "lib"
        lib_pkgs, lib_names = collect_lib()
        foreach(Pkg.develop, lib_pkgs)
    elseif set == "example"
        example_pkgs, example_names = collect_example()
        foreach(Pkg.develop, example_pkgs)
    end
end

"""
run Comonicon tests.

# Args

- `testset`: which testset to run, can be `all`, `Comonicon`, `lib`, `example`.

# Flags

- `--coverage`: enable code coverage tracking.
"""
@cast function runtest(testset::String="all"; coverage::Bool=false)
    root = dirname(@__DIR__)
    comonicon_jl = PackageSpec(path=root)

    lib_pkgs, lib_names = collect_lib()
    example_pkgs, example_names = collect_example()

    TestEnv.activate() do
        Pkg.develop(comonicon_jl)
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

@main
