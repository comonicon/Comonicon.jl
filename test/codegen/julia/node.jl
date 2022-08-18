module TestNodeCommand

using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body
using Test

function called()
    @test true
end

cmd = Entry(;
    version = v"1.2.0",
    root = NodeCommand(;
        name = "node",
        subcmds = Dict(
            "cmd1" => LeafCommand(; fn = called, name = "cmd1"),
            "cmd2" => LeafCommand(; fn = called, name = "cmd2"),
        ),
    ),
)

eval(emit(cmd))

@testset "test node" begin
    @test command_main(["cmd3"]) == 1
    @test command_main(["cmd1", "foo"]) == 1
    @test command_main(["cmd1", "foo", "-h"]) == 0
    @test command_main(["cmd1", "foo", "--version"]) == 0
    @test command_main(String[]) == 1
end

end
