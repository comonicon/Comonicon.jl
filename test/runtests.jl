using Comonicon
using Test
using Pkg

@testset "options" begin
    include("options.jl") 
end

@testset "ast" begin
    include("ast/ast.jl")
end

@testset "frontend" begin
    include("cast.jl")
    include("markdown.jl")
end

# @testset "projects" begin
#     include("projects.jl")
# end

# empty!(ARGS)
# push!(ARGS, "arg", "--opt1=2", "--opt2", "3", "-f")
# @test Base.include(Main, "scripts/hello.jl") == 0

# empty!(ARGS)
# push!(ARGS, "activate", "-h")
# @test Base.include(Main, "scripts/pkg.jl") == 0

# empty!(ARGS)
# push!(ARGS, "activate", "path", "--shared")
# @test Base.include(Main, "scripts/pkg.jl") == 0

# empty!(ARGS)
# push!(ARGS, "Author - Year.pdf")
# @test Base.include(Main, "scripts/searchpdf.jl") == 0
