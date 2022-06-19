using Test
using Comonicon

example_dir(xs...) = pkgdir(Comonicon, "example", xs...)

function execute(name, args::String = "")
    path = example_dir("$name.jl")
    cmd = Base.julia_cmd()
    return run(`$cmd --project=$(Base.active_project()) $(path) $args`)
end

@testset "lazyload $args" for args in ["", "random", "both", "none"]
    p = execute("lazyload", args)
    @test p.exitcode == 0
end
