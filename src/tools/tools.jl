module Tools

export prompt

prompt(msg, quiet::Bool = false) = prompt(stdin, msg, quiet)

function prompt(io::IO, msg, quiet::Bool = false)
    print(msg)

    if quiet
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
