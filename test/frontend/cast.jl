using Test
using ExproniconLite
using Comonicon.AST
using Comonicon
using Comonicon:
    JLArgument,
    JLOption,
    JLFlag,
    JLMD,
    JLMDFlag,
    JLMDOption,
    cast,
    cast_args,
    cast_flags,
    cast_options,
    default_name,
    get_version,
    split_leaf_command,
    split_docstring,
    read_arguments,
    read_description,
    read_options,
    read_flags,
    split_hint,
    split_option

args = [
    # name, type, require, vararg, default
    JLArgument(:arg1, Any, true, false, nothing),
    JLArgument(:arg2, Int, false, false, "1"),
    JLArgument(:arg3, String, false, false, "abc"),
]

flags = [JLFlag(:flag1), JLFlag(:flag2)]

options = [
    # name, type, hint
    JLOption(:option1, false, Any, "nothing"),
    JLOption(:option2, false, Int, "1::Int"),
    JLOption(:option3, false, String, "abc::String"),
]

"""
    foo(arg1, arg2::Int, arg3::String; kw...)

a test function.

# Args

- `arg1`: test argument.
- `arg2`: test argument.
- `arg3`: test argument.

# Options

- `--option1, -o`: test option.
- `--option2 <int>`: test option.
- `--option3=<name>`: test option.

# Flags
- `--flag1, -f`: test flag.
- `--flag2`: test flag.
"""
function foo(
    arg1,
    arg2::Int,
    arg3::String;
    option1 = nothing,
    option2::Int = 1,
    option3::String = "abc",
    flag1::Bool = false,
    flag2::Bool = false,
) end

@testset "cast(::Function, ...)" begin
    cmd = cast(foo, "foo", args, options, flags)

    @test cmd.fn === foo
    @test cmd.name == "foo"
    @test cmd.args[1].name == "arg1"
    @test cmd.args[1].vararg == false
    @test cmd.args[1].require == true
    @test cmd.args[1].default === nothing
    @test cmd.args[1].description.brief == "test argument."
    @test cmd.vararg === nothing
    @test cmd.flags["flag1"].name == "flag1"
    @test cmd.flags["f"].name == "flag1"
    @test cmd.flags["f"].short == true
    @test cmd.options["option1"].name == "option1"
    @test cmd.options["option2"].name == "option2"
    @test cmd.options["o"].short == true
    @test cmd.options["o"].hint === nothing

    @test cmd.options["option2"].short == false
    @test cmd.options["option2"].hint == "int"
    @test cmd.options["option2"].type === Int
    @test cmd.description == Description("a test function.")
    @test cmd.line == LineNumberNode(0)
end

@testset "split_leaf_command" begin

    @testset "basic" begin
        def = @expr JLFunction function foo(
            arg1,
            arg2::Int = 1,
            arg3::String = "abc";
            option1 = nothing,
            option2::Int = 1,
            option3::String = "abc",
            flag1::Bool = false,
            flag2::Bool = false,
        ) end

        args′, options′, flags′ = split_leaf_command(def)
        args′, options′, flags′ = eval(args′), eval(options′), eval(flags′)

        @test args′ == args
        @test options == options′
        @test flags == flags′

        def = @expr JLFunction function foo(; option1::Bool = true) end
        @test_throws ErrorException split_leaf_command(def)
    end

    @testset "required kwargs" begin
        def = @expr JLFunction function foo(
            arg1,
            arg2::Int = 1,
            arg3::String = "abc";
            option1,
            option2::Int,
            option3::String,
            flag1::Bool,
            flag2::Bool = false,
        ) end

        args′, options′, flags′ = split_leaf_command(def)
        args′, options′, flags′ = eval(args′), eval(options′), eval(flags′)

        @test options′ == [
            JLOption(:option1, true, Any, "<Any>"),
            JLOption(:option2, true, Int64, "<Int>"),
            JLOption(:option3, true, String, "<String>"),
            JLOption(:flag1, true, Bool, "<Bool>"),
        ]

        @test flags′ == [JLFlag(:flag2)]
    end
end


@test_throws ErrorException eval(:(module TestA
using Comonicon
@cast module Foo end
end))

module TestB
using Comonicon

@cast module Foo
using Comonicon
@cast foo(x) = 1
end
end

@testset "cast module" begin
    @test TestB.CASTED_COMMANDS["foo"].name == "foo"
    @test TestB.CASTED_COMMANDS["foo"] isa NodeCommand
    @test TestB.Foo.CASTED_COMMANDS["foo"].name == "foo"
    @test TestB.Foo.CASTED_COMMANDS["foo"] isa LeafCommand
end

module TestC
using Comonicon
@cast function command_a(a, b::String, c::Int; option_a = "abc") end
end

@testset "replace _ => -" begin
    @test haskey(TestC.CASTED_COMMANDS, "command-a")
    cmd = TestC.CASTED_COMMANDS["command-a"]
    @test cmd isa LeafCommand
    option = cmd.options["option-a"]
    @test option.name == "option-a"
    @test option.hint == "abc"
end

module TestD
using Test
using Comonicon
@cast foo(a) = nothing
@test_logs (:warn, "replacing command foo in the registry") @cast foo(a) = nothing
end

module TestE
using Comonicon
const COMMAND_VERSION = v"1.1.1"

@cast foo(a) = nothing
@main

end

@test TestE.CASTED_COMMANDS["main"].version == v"1.1.1"

module TestF
using Test
using Comonicon
@test_throws LoadError eval(:(@cast(1 + 1)))
end

module TestVararg
using Comonicon
@cast test_vararg(x, xs...) = nothing
@cast test_vararg_typed(x, xs::Int...) = nothing
end

@testset "test vararg" begin
    @test TestVararg.CASTED_COMMANDS["test-vararg"].vararg.name === "xs"
    @test TestVararg.CASTED_COMMANDS["test-vararg"].vararg.type === Any
    @test TestVararg.CASTED_COMMANDS["test-vararg-typed"].vararg.name === "xs"
    @test TestVararg.CASTED_COMMANDS["test-vararg-typed"].vararg.type === Int
end

module TestOptionalArg
using Comonicon
@cast test_optional(x, y = 1) = nothing
@cast test_optional_typed(x, y::Int = 2) = nothing
end

@testset "test optional arg" begin
    @test TestOptionalArg.CASTED_COMMANDS["test-optional"].args[2].name == "y"
    @test TestOptionalArg.CASTED_COMMANDS["test-optional"].args[2].require == false
    @test TestOptionalArg.CASTED_COMMANDS["test-optional"].args[2].default == "1"
    @test TestOptionalArg.CASTED_COMMANDS["test-optional"].args[2].type === Any

    @test TestOptionalArg.CASTED_COMMANDS["test-optional-typed"].args[2].name == "y"
    @test TestOptionalArg.CASTED_COMMANDS["test-optional-typed"].args[2].require == false
    @test TestOptionalArg.CASTED_COMMANDS["test-optional-typed"].args[2].default == "2"
    @test TestOptionalArg.CASTED_COMMANDS["test-optional-typed"].args[2].type === Int
end

module Test110

using Comonicon

@main function main(; niterations::Int = 3000, seed::Int = 1234, radius::Float64 = 1.5) end

end

@testset "issue 110" begin
    @test Test110.command_main(String[]) == 0
end
