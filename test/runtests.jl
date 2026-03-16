using Comonicon
using FromFile
using Test

@testset "compat" begin
    include("compat.jl")
end

@testset "options" begin
    include("options.jl")
end

@testset "argtype" begin
    include("argtype.jl")
end

@testset "ast" begin
    include("ast/ast.jl")
    include("ast/utils.jl")
end

@testset "frontend" begin
    include("frontend/cast.jl")
    include("frontend/markdown.jl")
    include("long_print.jl")
    include("vararg.jl")
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

@testset "example scripts" begin
    include("examples.jl")
end

# the script workaround doesn't work on MacOS
# https://github.com/actions/runner/issues/241
# @testset "tools" begin
#     include("tools.jl")
# end
