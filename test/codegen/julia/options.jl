module TestLeafOptions

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

const test_args = Ref{Vector{Any}}()
const test_kwargs = Ref{Vector{Any}}()

function foo(; kwargs...)
    test_kwargs[] = [kwargs...]
end

cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(;
        fn = foo,
        name = "leaf",
        options = Dict(
            "option-a" => Option(; sym = :option_a, hint = "int", type = Int, short = true),
            "option-b" => Option(; sym = :option_b, hint = "float64", type = Float64),
        ),
        flags = Dict(
            "flag-a" => Flag(; sym = :flag_a, short = true),
            "flag-b" => Flag(; sym = :flag_b),
        ),
    ),
)

eval(emit(cmd))

@testset "test leaf options" begin
    @test command_main(["--option-a=3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["-o=3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["-o3", "--option-b", "1.2", "-f", "--flag-b"]) == 0
    @test test_kwargs[] == [:option_a => 3, :option_b => 1.2, :flag_a => true, :flag_b => true]
    @test command_main(["--option-a", "--option-b", "1.2", "-f", "--flag-b"]) == 1
    @test command_main(["-o", "--option-b", "1.2", "-f", "--flag-b"]) == 1
end


cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(;
        fn = foo,
        name = "leaf",
        options = Dict(
            "option-a" => Option(; sym = :option_a, hint = "str", type = String, short = true),
            "option-b" => Option(; sym = :option_b, hint = "float64", type = Float64),
        ),
        flags = Dict(
            "flag-a" => Flag(; sym = :flag_a, short = true),
            "flag-b" => Flag(; sym = :flag_b),
        ),
    ),
)

eval(emit(cmd))

end

module TestStringType
using Test
using Comonicon

@cast function build(name::String; target::String = nothing)
    if target == "notebook"
    elseif target == "markdown"
    else
    end
end

@main

@testset "test String type" begin
    @test command_main(["build", "test", "--target=aaaa"]) == 0
end
end

module TestRequireOptions

using Test
using Comonicon

"""
# Options

- `--name=<string>`: name
"""
@main function run(;name::String, shots::Int)
    @test name == "test"
    @test shots == 2
end

@testset "TestRequireOptions" begin
    @test TestRequireOptions.command_main(["--name=test"]) == 1
    @test TestRequireOptions.command_main(["--name=test", "--shots=2"]) == 0
end

end
