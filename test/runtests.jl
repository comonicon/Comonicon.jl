using Comonicon
using Test
using Pkg

Comonicon.disable_cache()

@testset "cache flags" begin
    @test Comonicon.Parse.CACHE_FLAG[] == false
    Comonicon.enable_cache()
    @test Comonicon.Parse.CACHE_FLAG[] == true
end

Comonicon.disable_cache()

@testset "configurations" begin
    include("configurations.jl")
end

@testset "codegen" begin
    include("codegen.jl")
end

@testset "parse" begin
    include("parse.jl")
end

@testset "build" begin
    try
        include("build.jl")
    finally
        Pkg.rm(PackageSpec(name = "Foo"))
    end
end
