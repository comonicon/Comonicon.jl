using Comonicon
using Test
using Pkg

@testset "cast" begin
    include("cast.jl")
end

@testset "markdown" begin
    include("markdown.jl")
end
