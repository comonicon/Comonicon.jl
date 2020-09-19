using ArgMacros

function main()
    @inlinearguments begin
        @argumentdefault Int 1 opt1 "-o" "--opt1"
        @argumentdefault Int 2 opt2 "--opt2"
        @argumentflag flag "--flag"
        @positionaloptional String arg "arg"
    end

    println(" arg=>", arg)
    println(" opt1=>", opt1)
    println(" opt2=>", opt2)
    println(" flag=>", flag)
    return
end

main()
