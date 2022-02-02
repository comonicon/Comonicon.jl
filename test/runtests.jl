using Comonicon
using FromFile
using Test

@testset "compat" begin
    include("compat.jl")
end

@testset "options" begin
    include("options.jl")
end

@testset "ast" begin
    include("ast/ast.jl")
end

@testset "frontend" begin
    include("frontend/cast.jl")
    include("frontend/markdown.jl")
end

@testset "codegen" begin
    include("codegen/codegen.jl")
end

@testset "builder" begin
    include("builder/install.jl")
    include("builder/cli.jl")
end

@testset "scripts" begin
    include("scripts.jl")
end

@testset "tools" begin
    include("tools.jl")
end
