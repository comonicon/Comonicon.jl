using Comonicon
using Test
using Pkg

@testset "cast" begin
    include("cast.jl")
end

@testset "markdown" begin
    include("markdown.jl")
end

@testset "projects" begin
    include("projects.jl")
end

empty!(ARGS)
push!(ARGS, "arg", "--opt1=2", "--opt2", "3", "-f")
@test Base.include(Main, "scripts/hello.jl") == 0

empty!(ARGS)
push!(ARGS, "activate", "-h")
@test Base.include(Main, "scripts/pkg.jl") == 0

empty!(ARGS)
push!(ARGS, "activate", "path", "--shared")
@test Base.include(Main, "scripts/pkg.jl") == 0

empty!(ARGS)
push!(ARGS, "Author - Year.pdf")
@test Base.include(Main, "scripts/searchpdf.jl") == 0
