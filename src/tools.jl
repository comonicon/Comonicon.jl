module Tools

"""
    prompt(msg::AbstractString[, yes::Bool=false])

Prompt with message to ask user Yes or No.

# Arguments

- `msg`: the message to show in prompt.
- `yes`: skip the prompt and always return `true`, default is `false`.
"""
function prompt(msg::AbstractString, yes::Bool = false)
    prompt(yes) do
        print(msg)
    end
end

"""
    prompt(f, [io=stdin,] yes::Bool=false)

Prompt with custom printing to ask user Yes or No.

# Arguments

- `f`: a function with no arguments, which prints the prompt message.
- `io`: user input stream, default is `stdin`.
- `yes`: skip the prompt and always return `true`, default is `false`.
"""
prompt(f, yes::Bool=false) = prompt(f, stdin, yes)

function prompt(f, io::IO, yes::Bool = false)
    f() # print message
    if yes
        println(" Yes.")
    else
        print(" [Y/n] ")
        run(`stty raw`)
        input = read(io, Char)
        run(`stty cooked`)
        println()
        input in ['Y', 'y', '\n', '\r'] || return false
    end

    return true
end

end
