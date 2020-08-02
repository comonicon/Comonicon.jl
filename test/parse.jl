using Comonicon
using Comonicon.Types
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

@main name = "main" doc = """
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
    quiet = true,
    export_path = false,
)

@test isfile(Comonicon.PATH.project("test", "bin", "dummy"))
@test isfile(Comonicon.PATH.project("test", "bin", "dummy.jl"))
