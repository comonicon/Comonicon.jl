module Tools

export prompt

prompt(msg, yes::Bool = false) = prompt(stdin, msg, yes)

function prompt(io::IO, msg, yes::Bool = false)
    print(msg)

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

function cmd_error(msg::String)
    if get(ENV, "COMONICON_DEBUG", "OFF") == "ON"
        error(msg)
    else
        printstyled(msg, "\n"; color = :red, bold = true)
        exit(1)
    end
end

end
