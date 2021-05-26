module Hello

using Test
using Comonicon

"""
ArgParse example implemented in Comonicon.

# Arguments

- `x`: an argument, an argument

# Options

- `--opt1 <arg>`: an option
- `-o, --opt2 <arg>`: another option

# Flags

- `-f, --flag`: a flag
"""
@main function main(x; opt1 = 1, opt2::Int = 2, flag::Bool = false)
    @test x == "2"
    @test opt1 == "3"
    @test opt2 == 5
    @test flag == true
end

end # module
