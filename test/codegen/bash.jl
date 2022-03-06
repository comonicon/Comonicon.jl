using Test
using Comonicon
using Comonicon.Arg
using Comonicon.AST
using Comonicon.BashCompletions

# TODO: find a way to actually test the completions

called(x) = x

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

BashCompletions.emit(cmd) |> print

cmd = Entry(;
    version = v"1.2.0",
    root = NodeCommand(;
        name = "node",
        subcmds = Dict(
            "cmd1" => NodeCommand(;
                name = "cmd1",
                subcmds = Dict("cmd11" => LeafCommand(; fn = called, name = "cmd11")),
            ),
            "cmd2" => LeafCommand(; fn = called, name = "cmd2"),
        ),
    ),
)

BashCompletions.emit(cmd) |> print

foo(x) = x

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
            "option-a" => Option(; sym = :option_a, hint = "int", type = Int, short = true),
            "option-b" => Option(; sym = :option_b, hint = "float64", type = Float64),
        ),
        flags = Dict(
            "flag-a" => Flag(; sym = :flag_a, short = true),
            "flag-b" => Flag(; sym = :flag_b),
        ),
    ),
)

BashCompletions.emit(cmd) |> print
