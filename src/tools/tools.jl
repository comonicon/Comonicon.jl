module Tools

export prompt

prompt(msg) = prompt(stdin, msg)

function prompt(io::IO, msg)
    print(msg, "[Y/n]")
    read(io, Char) in ['Y', 'y', '\n'] || return false
    return true
end

end
