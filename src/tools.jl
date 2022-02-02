module Tools

using ..Comonicon: cmd_error

"""
    prompt(msg::AbstractString[, yes::Bool=false])

Prompt with message to ask user Yes or No.

# Arguments

- `msg`: the message to show in prompt.

# Keyword Arguments

- `yes`: skip the prompt and always return `true`, default is `false`.
- `require`: require user to input the answer explicitly. This will repeat
    3 times to ask user to input the answer then throw an [`CommandError`](@ref).
"""
function prompt(msg::AbstractString; yes::Bool = false, require::Bool = false)
    prompt(;yes, require) do
        print(msg)
    end
end

"""
    prompt(f, [io=stdin,] yes::Bool=false)

Prompt with custom printing to ask user Yes or No.

# Arguments

- `f`: a function with no arguments, which prints the prompt message.
- `io`: user input stream, default is `stdin`.

# Keyword Arguments

- `yes`: skip the prompt and always return `true`, default is `false`.
- `require`: require user to input the answer explicitly. This will repeat
    3 times to ask user to input the answer then throw an [`CommandError`](@ref).
"""
prompt(f; yes::Bool=false, require::Bool = false) = prompt(f, stdin; yes, require)

function prompt(f, io::IO; yes::Bool = false, require::Bool = false)
    if yes
        f() # print message
        println(" Yes.")
    elseif require
        msg = "expect yes (y) or no (n)"
        for _ in 1:3
            f() # print message
            print(" [y/n] ")
            input = yes_or_no(io)
            println()
            (input == 'Y' || input == 'y') && return true
            (input == 'N' || input == 'n') && return false
            println(msg)
        end
        cmd_error(msg)
    else
        f() # print message
        print(" [Y/n] ")
        input = yes_or_no(io)
        println()
        input in ['Y', 'y', '\n', '\r'] || return false
    end
    return true
end

function yes_or_no(io::IO)
    run(`stty raw -F /dev/tty`)
    input = read(io, Char)
    run(`stty cooked -F /dev/tty`)
    return input
end

end
