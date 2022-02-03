module TestLeafArgument

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

function foo(a::Int)
    @test a == 3
end

cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(; fn = :foo, name = "leaf", args = [Argument(; name = "a", type = Int)]),
)

eval(emit(cmd))

@testset "test leaf argument" begin
    @test command_main(["3"]) == 0
    @test command_main(["1.2"]) == 1
end

end

module Issue141

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

function main(xs...)
    @test xs == ("1", "2", "3")
end

cmd = Entry(
    LeafCommand(
        main,
        "main",
        Argument[],
        0,
        Argument("xs", Any, true, false, nothing, Description(), LineNumberNode(0)),
        Dict{String,Flag}(),
        Dict{String,Option}(),
        Description("", ""),
        LineNumberNode(0),
    ),
    nothing,
    LineNumberNode(0),
)

eval(emit(cmd))

@testset "issue/#141" begin
    Issue141.command_main(["1", "2", "3"])
end

end
