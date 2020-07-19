# using Comonicon

# @command_main function foo(x; opt1=1, opt2::Int=2, flag=false)
#     println("Parsed args:")
#     println("flag=>", flag)
#     println("arg=>", x)
#     println("opt1=>", opt1)
#     println("opt2=>", opt2)
# end

# command_main()


function foo(x; opt1=1, opt2::Int=2, flag=false)
    println("Parsed args:")
    println("flag=>", flag)
    println("arg=>", x)
    println("opt1=>", opt1)
    println("opt2=>", opt2)
end

# @command_main

# command_main()

# write("cmd.jl", Comonicon.main())

include("cmd.jl")
