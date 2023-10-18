using Comonicon: @main


"""
"""
@main function test(name::Union{String, Nothing} = nothing)
    println(name)
    return
end
