using Comonicon.Types
using Comonicon.CodeGen
using Comonicon.PATH
using Comonicon.CodeGen: codegen_call
using Test

function test_sin(theta; foo = 1.0)
    @test theta == "1.0"
    @test foo == "2.0"
end

function test_cos(theta::AbstractFloat)
    @test theta == 2.0
end

function test_tanh(theta::Real)
    @test theta == 3.0
end


opt = Option("foo", Arg("theta"); short = true, doc = "sadasd aasdas dsadas dasdasdasd asdasdas")
cmd_sin = LeafCommand(
    test_sin;
    args = [Arg("theta")],
    options = [opt],
    doc = "sdasdbsa dasdioasdmasd dsadas",
)
cmd_cos = LeafCommand(
    test_cos;
    args = [Arg("theta"; type = AbstractFloat)],
    doc = "dasdas dasidjmoasid dasdasd dasdasd dasd dasd",
)
cmd1 = NodeCommand("foo", [cmd_sin, cmd_cos]; doc = "asdasd asdasd asd asdasd asdas asdasd dasdas")
cmd2 = NodeCommand(
    "goosadas",
    [LeafCommand(test_tanh; args = [Arg("theta"; type = Real)])],
    doc = "asdasdasdasdfunuikasnsdasdasdasdas",
)
cmd = NodeCommand("dummy", [cmd1, cmd2]; doc = "dasdasdujkink. asdas dasdas das dasd asdasd adsd as.")
entry = EntryCommand(cmd)
eval(codegen(entry))

@test command_main(["foo", "test_cos", "2"]) == 0
@test command_main(["foo", "test_sin", "1.0", "--foo=2.0"]) == 0
@test command_main(["foo", "test_sin", "1.0", "--foo", "2.0"]) == 0
@test command_main(["foo", "test_sin", "1.0", "-f2.0"]) == 0

@test strip(codegen(ZSHCompletionCtx(), entry)) == strip(read(PATH.project("test", "_dummy"), String))

@testset "prettify" begin
    ex1 = quote
        if x > 0
            begin
                x += 1
            end
        end
    end

    ex2 = quote
        if x > 0
            x += 1
        end
    end

    @test prettify(ex1) == prettify(ex2)
end

module Issue23

using Comonicon, Test

@cast function run(host = "127.0.0.1"; port::Int = 1234, launchbrowser::Bool = false)
    @test host == "127.0.0.1"
    @test port == 2345
end

@main
end

Issue23.command_main(["run", "--port", "2345"])

@testset "varargs" begin

    cmd_sin = LeafCommand(
        test_sin;
        args = [Arg("theta"), Arg("xs"; vararg = true)],
        doc = "sdasdbsa dasdioasdmasd dsadas",
    )

    @test codegen_call(ASTCtx(), :params, :n_args, cmd_sin) == :($test_sin(ARGS[1], ARGS[2:end]...))

    cmd_sin = LeafCommand(
        test_sin;
        args = [Arg("theta"), Arg("alpha"; require = false), Arg("xs"; vararg = true)],
        doc = "sdasdbsa dasdioasdmasd dsadas",
    )

    @test prettify(codegen_call(ASTCtx(), :params, :n_args, cmd_sin)) == Expr(
        :block,
        Expr(:if, :(n_args == 1), :($test_sin(ARGS[1]))),
        Expr(:if, :(n_args == 2), :($test_sin(ARGS[1], ARGS[2]))),
        Expr(:if, :(n_args == 3), :($test_sin(ARGS[1], ARGS[2], ARGS[3:end]...))),
    )

    cmd_sin = LeafCommand(
        test_sin;
        args = [Arg("theta"; type = Float32), Arg("xs"; type = Int, vararg = true)],
        doc = "sdasdbsa dasdioasdmasd dsadas",
    )

    ex = prettify(codegen_call(ASTCtx(), :params, :n_args, cmd_sin))
    target = :($test_sin(
        convert($Float32, Meta.parse(ARGS[1])),
        map(x -> convert($Int64, Meta.parse(x)), ARGS[2:end])...,
    ))
    target = prettify(target)
    @test ex == target

end

module Issue110

using Comonicon
using Test

@main function main(; niterations::Int = 3000, seed::Int = 1234, radius::Float64 = 1.5)
    @test niterations == 2345
    @test seed == 42
    @test radius == 1.1
end

end

Issue110.command_main(["--niterations=2345", "--seed=42", "--radius=1.1"])
