using Comonicon
using Test

Comonicon.disable_cache()

@testset "codegen" begin
    include("codegen.jl")
end

@testset "parse" begin
    include("parse.jl")
end

@testset "build" begin
    include("build.jl")
end
