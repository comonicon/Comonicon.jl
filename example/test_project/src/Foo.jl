module Foo

using Comonicon

"""
ArgParse example implemented in Comonicon.

# Arguments

- `x`: an argument, an argument

# Options

- `--opt1 <arg>`: an option
- `--opt2, -o <arg>`: another option

# Flags

- `--flag, -f`: a flag
"""
@main function main(x; opt1 = 1, opt2::Int = 2, flag = false)
    println("Parsed args:")
    println("flag=>", flag)
    println("arg=>", x)
    println("opt1=>", opt1)
    println("opt2=>", opt2)
end

end
