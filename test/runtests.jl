using Comonicon
using Test

@testset "codegen" begin
    include("codegen.jl")
end

@testset "parse" begin
    include("parse.jl")
end
