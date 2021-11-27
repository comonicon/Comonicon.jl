module TestLeafVararg

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

const test_args = Ref{Vector{Any}}()

function foo(a, b=2, c...)
    test_args[] = [a, b, c...]
end

cmd = Entry(;
    version=v"1.1.0",
    root=LeafCommand(;
        fn=foo,
        name="leaf",
        args=[
            Argument(;name="a", type=Int),
            Argument(;name="b", type=Int, require=false),
        ],
        vararg=Argument(;name="c", type=Float64, vararg=true),
    )
)

eval(emit(cmd))

@testset "test leaf optional argument" begin
    @test command_main(["3", "2", "5.5", "6", "7"]) == 0
    @test test_args[] == Any[3, 2, 5.5, 6.0, 7.0]
    @test command_main(["3", "2"]) == 0
    @test test_args[] == Any[3, 2]
end

end
