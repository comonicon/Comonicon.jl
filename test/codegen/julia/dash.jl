module TestDash

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

const test_args = Ref{Vector{Any}}()
const test_kwargs = Ref{Vector{Any}}()

function foo(a, b = 2, c...; kwargs...)
    test_args[] = [a, b, c...]
    test_kwargs[] = [kwargs...]
end

cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(;
        fn = foo,
        name = "leaf",
        args = [
            Argument(; name = "a", type = Int),
            Argument(; name = "b", type = Int, require = false),
        ],
        vararg = Argument(; name = "c", type = Int, vararg = true),
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

@testset "test leaf optional argument" begin
    @test command_main(["3", "2", "5", "6", "7", "--option-a=2", "--option-b", "2.3"]) == 0
    @test test_args[] == Any[3, 2, 5, 6, 7]
    @test test_kwargs[] == [:option_a => 2, :option_b => 2.3]

    @test command_main(["--option-a=2", "--option-b=2.3", "--", "3", "2"]) == 0
    @test test_args[] == Any[3, 2]
    @test test_kwargs[] == [:option_a => 2, :option_b => 2.3]

    @test command_main(["3", "2"]) == 0
    @test test_args[] == Any[3, 2]

    @test command_main(["cmd", "--", "3", "2"]) == 1
end

end
