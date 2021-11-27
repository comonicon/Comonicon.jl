using Pkg
root = dirname(@__DIR__)
Pkg.activate(root)
using TestEnv
TestEnv.activate() do
    Pkg.develop(PackageSpec(path=joinpath(root, "lib", "ComoniconTestUtils")))
    Pkg.develop(PackageSpec(path=joinpath(root, "example", "FakePkg")))
    Pkg.develop(PackageSpec(path=joinpath(root, "example", "Hello")))

    Pkg.test("Comonicon"; coverage=true)
    Pkg.test("ComoniconTestUtils"; coverage=true)
    Pkg.test("FakePkg"; coverage=true)
    Pkg.test("Hello"; coverage=true)
end
