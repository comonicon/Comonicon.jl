using ComoniconTestUtils
using Comonicon.ZSHCompletions
using Test
using Random

Random.seed!(42)

@testset "test completion" for _ in 1:5
    cmd = rand_command()
    script = ZSHCompletions.emit(cmd)
    @test occursin("#compdef _$(cmd.root.name) $(cmd.root.name)", script)
    @test occursin("function _$(cmd.root.name)() {", script)
end

using Comonicon.Arg
using Comonicon.AST
using Comonicon.ZSHCompletions

foo(a, b) = a

cmd = Entry(;
    version = v"1.2.0",
    root = NodeCommand(;
        name = "node",
        subcmds = Dict(
            "cmd1" => NodeCommand(;
                name = "cmd1",
                subcmds = Dict("cmd11" => LeafCommand(; fn = identity, name = "cmd11")),
            ),
            "cmd2" => LeafCommand(; fn = identity, name = "cmd2"),
        ),
    ),
)

ZSHCompletions.emit(cmd) |> print

cmd = Entry(;
    version = v"1.1.0",
    root = LeafCommand(;
        fn = foo,
        name = "leaf",
        args = [
            Argument(; name = "path", type = Arg.Path),
            Argument(; name = "dir", type = Arg.DirName, require = false),
        ],
        vararg = Argument(; name = "c", type = Int, vararg = true),
        options = Dict(
            "option-a" => Option(;
                sym = :option_a,
                hint = "int",
                type = Int,
                short = true,
                description = "test",
            ),
            "option-b" => Option(; sym = :option_b, hint = "float64", type = Float64),
        ),
        flags = Dict(
            "flag-a" => Flag(; sym = :flag_a, short = true),
            "flag-b" => Flag(; sym = :flag_b),
        ),
    ),
)

ZSHCompletions.emit(cmd) |> print
