using Comonicon
@main foo(xs::Vararg{String}) = foreach(println, xs)
