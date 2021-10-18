using Test
using Markdown
using ComoniconTypes
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

@testset "read_arguments" begin
    doc = Markdown.parse("""
        command <args>

    description of the command.

    # Args

    - `arg1`: argument 1.
    - `arg2`: argument 2.
    - `arg3`: argument 3.
    - `arg4`: argument 4.
    """)

    @test read_description(doc) == "description of the command."

    args = read_arguments(doc)
    @test args["arg1"] == "argument 1."
    @test args["arg2"] == "argument 2."
    @test args["arg3"] == "argument 3."
    @test args["arg4"] == "argument 4."

    doc = Markdown.parse("""
    description of the command.

    # Arguments

    - `arg1`: argument 1.
    - `arg2`: argument 2.
    - `arg3`: argument 3.
    - `arg4`: argument 4.
    """)

    @test read_description(doc) == "description of the command."

    args = read_arguments(doc)
    @test args["arg1"] == "argument 1."
    @test args["arg2"] == "argument 2."
    @test args["arg3"] == "argument 3."
    @test args["arg4"] == "argument 4."
end

@testset "split_hint" begin
    @test split_hint("long") == ("long", nothing)
    @test split_hint("long <value>") == ("long", "value")
    @test split_hint("long=<value>") == ("long", "value")
    @test split_hint("s") == ("s", nothing)
    @test split_hint("s=<value>") == ("s", "value")
    @test split_hint("s <value>") == ("s", "value")
    @test_throws Meta.ParseError split_hint("s=s")
    @test_throws Meta.ParseError split_hint("s=s=s")
end

@testset "split_option" begin
    @test split_option("--long") == ("long", nothing, nothing)
    @test split_option("--long <value>") == ("long", nothing, "value")
    @test split_option("--long=<value>") == ("long", nothing, "value")
    @test split_option("--short, -s") == ("short", "s", nothing)
    @test split_option("--short, -s <value>") == ("short", "s", "value")
    @test split_option("--short, -s=<value>") == ("short", "s", "value")
    @test_throws Meta.ParseError split_option("--short, -ss, -st")
    @test_throws Meta.ParseError split_option("--short, -ss")
    @test_throws Meta.ParseError split_option("--short, -ss=<value>")
    @test_throws Meta.ParseError split_option("--short, -t=<value>")
end

@testset "read_options" begin
    doc = Markdown.parse("""
    description of the command.

    # Options

    - `--short, -s`: short option using default hint.
    - `--short-space, -s <value>`: short option using given hint.
    - `--short-assign, -s=<value>`: short option using given hint.
    - `--long`: long option using default hint.
    - `--long-space <value>`: long option using given hint.
    - `--long-assign=<value>`: long option using given hint.
    - `--short_underscore, -s <value>`: short option with underscore.
    """)

    options = read_options(doc)
    @test options["short"] == JLMDOption(nothing, "short option using default hint.", true)
    @test options["short-space"] == JLMDOption("value", "short option using given hint.", true)
    @test options["short-assign"] == JLMDOption("value", "short option using given hint.", true)
    @test options["long"] == JLMDOption(nothing, "long option using default hint.", false)
    @test options["long-space"] == JLMDOption("value", "long option using given hint.", false)
    @test options["long-assign"] == JLMDOption("value", "long option using given hint.", false)
    @test options["short-underscore"] == JLMDOption("value", "short option with underscore.", true)
end

@testset "read_flags" begin
    doc = Markdown.parse("""
    description of the command.

    # Flags

    - `--short, -s`: short flag.
    - `--short-space, -s`: short flag with dash.
    - `--long`: long flag.
    - `--long-space`: long flag with dash.
    """)

    flags = read_flags(doc)
    @test flags["short"] == JLMDFlag("short flag.", true)
    @test flags["short-space"] == JLMDFlag("short flag with dash.", true)
    @test flags["long"] == JLMDFlag("long flag.", false)
    @test flags["long-space"] == JLMDFlag("long flag with dash.", false)
end

@testset "split_docstring" begin
    content = Markdown.parse("""
    description of the command.

    # Args

    - `arg1`: argument 1.
    - `arg2`: argument 2.
    - `arg3`: argument 3.
    - `arg4`: argument 4.

    # Options

    - `--short, -s`: short option using default hint.
    - `--short-space, -s <value>`: short option using given hint.
    - `--short-assign, -s=<value>`: short option using given hint.
    - `--long`: long option using default hint.
    - `--long-space <value>`: long option using given hint.
    - `--long-assign=<value>`: long option using given hint.
    - `--short_underscore, -s <value>`: short option with underscore.

    # Flags

    - `--short, -s`: short flag.
    - `--short-space, -s`: short flag with dash.
    - `--long`: long flag.
    - `--long-space`: long flag with dash.
    """)

    doc = split_docstring(content)
    @test doc.desc == "description of the command."
    @test doc.arguments["arg1"] == "argument 1."
    @test doc.flags["long"] == JLMDFlag("long flag.", false)
    @test doc.options["long"] == JLMDOption(nothing, "long option using default hint.", false)
end

@testset "reverse order" begin
    content = Markdown.parse("""
    description of the command.
    
    # Options
    
    - `-o, --option=<value>`: some random option.
    - `-o,--option_space=<value>`: some random option.
    """)
    
    doc = split_docstring(content)
    
    @test doc.options["option"] == JLMDOption("value", "some random option.", true)
    @test doc.options["option-space"] == JLMDOption("value", "some random option.", true)

    content = Markdown.parse("""
    description of the command.
    
    # Options
    
    - `-o, option=<value>`: some random option.
    """)

    @test_throws ErrorException split_docstring(content)
end
