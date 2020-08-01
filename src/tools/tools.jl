module Tools

export prompt

prompt(msg, quiet::Bool=false) = prompt(stdin, msg, quiet)

function prompt(io::IO, msg, quiet::Bool=false)
    print(msg)

    if quiet
        println(" Yes.")
    else
        print(" [Y/n]")
        read(io, Char) in ['Y', 'y', '\n'] || return false
    end

    return true
end

end
