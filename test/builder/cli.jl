using Test
using Comonicon.Options
using Comonicon.Builder: print_builder_help, command_main

function with_args(f, args::Vector{String})
    old = copy(ARGS)
    empty!(ARGS)
    append!(ARGS, args)
    ret = f()
    empty!(ARGS)
    append!(ARGS, old)
    return ret
end

module TestCLI end

@testset "CLI help info" begin
    options = Options.Comonicon(name="test")
    @test with_args(["-h"]) do
        command_main(TestCLI, options)
    end === nothing
    
    @test with_args(["aaahelp"]) do
        command_main(TestCLI, options)
    end === nothing
end
