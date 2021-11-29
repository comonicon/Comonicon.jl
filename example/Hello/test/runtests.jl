using Test
using Hello

@testset "hello" begin
    @test Hello.command_main(["-h"]) == 0
    @test Hello.command_main(["--help"]) == 0
    @test Hello.command_main(["2", "--opt1=3", "--opt2", "5", "-f"]) == 0
    @test Hello.command_main(["2", "--opt1=3", "--opt2", "5", "--flag"]) == 0
end
