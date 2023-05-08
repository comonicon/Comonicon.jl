module TestPlugin

using Test
using Comonicon.AST
using Comonicon.JuliaExpr
using Comonicon.JuliaExpr: emit, emit_body, emit_norm_body, emit_dash_body

function called()
    @test false
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

eval(emit(cmd, JuliaExpr.Configs(plugin = true)))
end

using Test
using Comonicon
if Sys.iswindows()
    @test_broken false
else
    withenv("PATH" => "$(pkgdir(Comonicon, "test", "codegen", "julia")):$(ENV["PATH"])") do
        Sys.which("node-cmd3")
        @test TestPlugin.command_main(["cmd3"]) == 0
    end
end
