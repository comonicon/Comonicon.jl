module TestBuilderCLI

using Test
using Comonicon.Options
using Comonicon.Builder: print_builder_help, command_main
using FromFile

@from "../utils.jl" import with_args

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

end
