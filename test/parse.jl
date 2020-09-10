using Comonicon
using Markdown
using Comonicon.Types
using Comonicon.Parse
using Comonicon.BuildTools: precompile_script, install
using Test

module Dummy
using Comonicon
using Test

"""
foo foo

# Arguments

- `x`: an argument

# Options

- `--foo <foo>`: foo foo
"""
@cast function foo(x::Int, y; foo::Int = 1, hulu::Float64 = 2.0, flag::Bool = false) where {T}
    @test x == 1
    @test y == "2.0"
    @test foo == 2
    @test hulu == 3.0
    @test flag == true
end

"""
goo goog gooasd dasdas

goo asdas dasd assadas

# Arguments

- `ala`: ala ahjsd asd wvxzj
- `gaga`: djknawd sddasd kw

# Options

- `-g,--giao <name>`: huhuhuhuhuuhu

# Flags

- `-f,--flag`: dadsa fasf gas
"""
@cast function goo(ala::Int, gaga; giao = "Bob", flag::Bool = false)
    @test ala == 1
    @test gaga == "2.0"
    @test giao == "Sam"
    @test flag == true
end

"""
tick tick.

# Arguments

- `xx`: xxxxxxxxxxxx
- `yy`: yyyyyyyyyyyy
"""
@cast function tick(xx::Int, yy::Float64 = 1.0)
    @test xx == 1
    @test yy in [1.0, 2.0]
end

@main name = "dummy" doc = """
    dummy command. dasdas dsadasdnaskdas dsadasdnaskdas
    sdasdasdasdasdasd adsdasdas dsadasdas dasdasd dasda
    """
end

@test Dummy.command_main(String["foo", "1.0", "2.0", "--foo", "2", "--hulu=3.0", "--flag"]) == 0
@test Dummy.command_main(String["foo", "1.0", "2.0", "--foo", "2", "--hulu=3.0", "-f"]) == 0
@test Dummy.command_main(String["goo", "1.0", "2.0", "-gSam", "-f"]) == 0
@test_throws ErrorException LeafCommand(
    identity;
    name = "foo",
    options = [Option("huhu"; short = true)],
)
@test Dummy.command_main(String["tick", "1.0", "2.0"]) == 0
@test Dummy.command_main(String["tick", "1.0"]) == 0


@test precompile_script(Dummy) == """
using Main.Dummy;
Main.Dummy.command_main(["-h"]);
Main.Dummy.command_main(["goo", "-h"]);
Main.Dummy.command_main(["tick", "-h"]);
Main.Dummy.command_main(["foo", "-h"]);
"""

empty!(ARGS)
append!(ARGS, ["2", "--opt1", "3"])

"""
ArgParse example implemented in Comonicon.

# Arguments

- `x`: an argument

# Options

- `--opt1 <arg>`: an option
- `-o, --opt2 <arg>`: another option

# Flags

- `-f, --flag`: a flag
"""
@main function main(x; opt1 = 1, opt2::Int = 2, flag = false)
    @test flag == false
    @test x == "2"
    @test opt1 == "3"
    @test opt2 == 2
end

Comonicon.install(
    Dummy;
    bin = Comonicon.PATH.project("test", "bin"),
    completion = false,
    quiet = false,
)

@test isfile(Comonicon.PATH.project("test", "bin", "dummy"))
@test isfile(Comonicon.PATH.project("test", "bin", "dummy.jl"))

@testset "default_name" begin
    @test Comonicon.Parse.default_name("Foo.jl") == "foo"
    @test Comonicon.Parse.default_name(sin) == "sin"
end

cmd = @cast(f_issue_47(xs::Int...) = xs)

@testset "issue/#47" begin
    @test cmd.args[1].type == Int
    @test cmd.args[1].vararg == true
end

@testset "disable version in @main" begin
    @test_throws Meta.ParseError Parse.create_entry(
        Main,
        QuoteNode(LineNumberNode(1)),
        Expr(:kw, :version, "0.1.0"),
    )
end

@testset "markdown parsing" begin
    doc = md"""
    ArgParse example implemented in `Comonicon`.

    # Arguments

    - `x`: an argument, `args`
    """

    intro, args, flags, optionsa = Parse.read_doc(doc)
    @test intro == "  ArgParse example implemented in \e[36mComonicon\e[39m."
    @test haskey(args, "x")
    @test args["x"] == "an argument, \e[36margs\e[39m"

    doc = md"""
    ArgParse example implemented in Comonicon.

    # Args
    - `x`: an argument

    # Options

    - `--option1=<value>`: option with assign
    - `--option2=<value>`: option with space
    """

    intro, args, flags, options = Parse.read_doc(doc)
    @test intro == "  ArgParse example implemented in Comonicon."
    @test haskey(args, "x")
    @test args["x"] == "an argument"
    @test haskey(options, "option1")
    @test haskey(options, "option2")
    @test options["option1"] == ("value", "option with assign", false)
    @test options["option2"] == ("value", "option with space", false)

    doc = md"""
    ArgParse example implemented in Comonicon.

    # Args
    - `x`: an argument

    # Arguments
    - `x`: an argument
    """

    @test_throws ErrorException Parse.read_doc(doc)
end
