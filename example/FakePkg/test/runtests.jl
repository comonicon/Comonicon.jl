using Test
using FakePkg
using FromFile
using Comonicon.Builder

@testset "FakePkg" begin
    @test FakePkg.CASTED_COMMANDS["main"].root.name == "pkg"

    @test FakePkg.command_main(["-h"]) == 0
    @test FakePkg.command_main(["--help"]) == 0
    @test FakePkg.command_main(["-V"]) == 0
    @test FakePkg.command_main(["--version"]) == 0

    @test FakePkg.command_main(["add", "-h"]) == 0
    @test FakePkg.command_main(["rm", "-h"]) == 0
    @test FakePkg.command_main(["noarguments", "-h"]) == 0

    @test FakePkg.command_main(["rm", "CCC", "-h"]) == 0
    @test FakePkg.command_main(["add", "CCC", "-h"]) == 0

    @test FakePkg.command_main(["add", "ABC"]) == 0
    @test FakePkg.command_main(["rm", "ABC"]) == 0
    @test FakePkg.command_main(["activate", "fake", "-s"]) == 0
    @test FakePkg.command_main(["activate", "fake", "--shared"]) == 0

    @test FakePkg.command_main(["registry", "add", "abc"]) == 0
    @test FakePkg.command_main(["registry", "rm", "abc"]) == 0
end

using Comonicon.Options: read_options, get_path, @asset_str

@testset "test assets path" begin
    options = read_options(FakePkg)
    for asset in options.application.assets
        @test ispath(get_path(FakePkg, asset))
    end
end

@from "../../../test/utils.jl" import with_args

@testset "build package" begin
    @test with_args(["-h"]) do
        FakePkg.comonicon_build()
    end == 0
    
    @test with_args() do
        FakePkg.comonicon_build()
    end == 0
    
    @test isfile(joinpath(".julia", "bin", "pkg"))
    if haskey(ENV, "SHELL") && basename(ENV["SHELL"]) == "zsh"
        @test isfile(joinpath(".julia", "completions", "_pkg"))
    end

    @test with_args(["sysimg"]) do
        FakePkg.comonicon_build()
    end == 0

    @test with_args(["sysimg", "tarball"]) do
        FakePkg.comonicon_build()
    end == 0

    @test with_args(["app"]) do
        FakePkg.comonicon_build()
    end == 0

    @test with_args(["app", "tarball"]) do
        FakePkg.comonicon_build()
    end == 0

    @test isdir("build")
    @test isfile(Builder.tarball_name(FakePkg, "pkg", "application"))
end
