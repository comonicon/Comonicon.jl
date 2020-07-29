using Comonicon

"""
my command line interface.

# Arguments

- `arg`: an argument

# Options

- `-o, --option <name>`: an option that has short option.

# Flags

- `-f, --flag`: a flag that has short flag.
"""
@main function mycmd(arg; option = "Sam", flag::Bool = false)
    @show arg
    @show option
    @show flag
end
