using Test
using Comonicon
using Expronicon
using Comonicon.Runtime

module TestE

using Test
using Comonicon

"""
Test command.

# Args

- `a`: argument a.
- `b`: argument b.
- `c`: argument c.

# Options

- `--short, -s`: short option.
- `--option-a=<int>`: option a.
- `--option-b <str>`: option b.

# Flags

- `--flag, -f`: flag.
"""
@cast function foo(a, b::String, c::Int; option_a::Int=1, option_b::String="abc", flag::Bool=false, short::Int=5)
    @test a == "name"
    @test b == "string"
    @test c == 1
    @test option_a == 3
    @test option_b == "bcd"
    @test flag
    @test short == 4
    return
end

end

cmd = TestE.CASTED_COMMANDS["foo"]
cmd = CLIEntry(;root=cmd, version=v"0.1.0")

interpret(cmd, ["name", "string", "1", "--option-a", "3", "--option-b=bcd", "-f", "-s4"])
interpret(cmd, ["name", "string", "1", "--option-a", "3", "--option-b", "bcd", "-f", "-s", "4"])
interpret(cmd, ["name", "string", "1", "--option-a", "3", "--option-b", "bcd", "--flag", "-s", "4"])

buf = IOBuffer()
@test interpret(buf, cmd, ["name", "string", "1", "--option-a", "3", "--option-b", "bcd", "-flag", "-s", "4"]) == -1
msg = String(take!(buf))
@test occursin("Error: expect -f or --flag, got -flag", msg)

interpret(cmd, ["--option-a", "3", "--option-b", "bcd", "--flag", "-s", "4", "name", "string", "1"])
interpret(cmd, ["--option-a", "3", "--option-b", "bcd", "--flag", "-s", "4", "--", "name", "string", "1"])

buf = IOBuffer()
@test interpret(buf, cmd, ["name", "string", "1", "--", "--option-a", "3", "--option-b=bcd", "-f", "-s4"]) == -1
msg = String(take!(buf))
@test occursin("Error: expect at most 3 args, got 5", msg)

module Test114

using Test
using Comonicon

"""
Test command.

# Args

- `name`: argument.

# Options

- `--option, -o`: option.
"""
@cast function foo(name::String; option::String="abc")
    @test name == "Author - Year.pdf"
    @test option == "Author - Year.pdf"
    return
end

@main

end

@testset "issue#114" begin
    Test114.command_main(["foo", "Author - Year.pdf", "--option", "Author - Year.pdf"])
end
