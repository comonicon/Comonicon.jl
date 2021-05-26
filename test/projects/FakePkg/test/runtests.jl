using Test
using FakePkg

@testset "FakePkg" begin
    @test FakePkg.CASTED_COMMANDS["main"].root.name == "pkg"

    @test FakePkg.command_main(["-h"]) == 0
    @test FakePkg.command_main(["--help"]) == 0
    @test FakePkg.command_main(["-V"]) == 0
    @test FakePkg.command_main(["--version"]) == 0

    @test FakePkg.command_main(["add", "-h"]) == 0
    @test FakePkg.command_main(["rm", "-h"]) == 0

    @test FakePkg.command_main(["rm", "CCC", "-h"]) == 0
    @test FakePkg.command_main(["add", "CCC", "-h"]) == 0

    @test FakePkg.command_main(["add", "ABC"]) == 0
    @test FakePkg.command_main(["rm", "ABC"]) == 0
    @test FakePkg.command_main(["activate", "fake", "-s"]) == 0
    @test FakePkg.command_main(["activate", "fake", "--shared"]) == 0

    @test FakePkg.command_main(["registry", "add", "abc"]) == 0
    @test FakePkg.command_main(["registry", "rm", "abc"]) == 0
end
