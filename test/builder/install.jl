module TestBuilderInstall

using Test
using Scratch
using Comonicon.Configs
using Comonicon.Builder: ensure_path, entryfile_script, completion_script, detect_rcfile

@testset "ensure_path" begin
    path = tempname()
    @test ispath(path) == false
    ensure_path(path)
    @test ispath(path) == true
end

module TestInstall

using Comonicon

@cast foo(x) = 0
@cast goo(x) = 1

@main

end

@testset "entryfile_script" begin
    options = Configs.Comonicon(name = "test")
    script = entryfile_script(TestInstall, options)
    if Sys.iswindows()
        @test occursin("@echo off", script)
        @test occursin("set JULIA_PROJECT=$(get_scratch!(TestInstall, "env"))", script)
        julia_exe = joinpath(Sys.BINDIR, Base.julia_exename())
        @test occursin("$julia_exe ^\n", script)
        @test occursin("--startup-file=no ^\n", script)
        @test occursin("--color=yes ^\n", script)
        @test occursin("--compile=yes ^\n", script)
        @test occursin("--optimize=2 ^\n", script)
        @test occursin(
            "using Main.TestBuilderInstall.TestInstall; exit(TestInstall.command_main())",
            script,
        )
    else
        @test occursin("#!/usr/bin/env bash", script)
        @test occursin("JULIA_PROJECT=$(get_scratch!(TestInstall, "env"))", script)
        julia_exe = joinpath(Sys.BINDIR, Base.julia_exename())
        @test occursin("exec $julia_exe \\\n", script)
        @test occursin("--startup-file=no \\\n", script)
        @test occursin("--color=yes \\\n", script)
        @test occursin("--compile=yes \\\n", script)
        @test occursin("--optimize=2 \\\n", script)
        @test occursin("-- \"\${BASH_SOURCE[0]}\"", script)
        @test occursin(
            "using Main.TestBuilderInstall.TestInstall\nexit(TestInstall.command_main())",
            script,
        )
    end
end

@testset "test completion script" begin
    options = Configs.Comonicon(name = "test")
    withenv("SHELL" => "/bin/zsh") do
        script = completion_script(TestInstall, options, "zsh")
        @test occursin("#compdef _testinstall testinstall \n", script)
    end

    withenv("SHELL" => "/bin/fakesh") do
        @test_throws ErrorException completion_script(TestInstall, options, "/bin/fakesh")
    end
end

@testset "detect_rcfile" begin
    answer = joinpath((haskey(ENV, "ZDOTDIR") ? ENV["ZDOTDIR"] : homedir()), ".zshrc")
    withenv("SHELL" => "zsh") do
        @test detect_rcfile("zsh") == answer
    end

    withenv("SHELL" => "zsh", "ZDOTDIR" => "zsh_dir") do
        @test detect_rcfile("zsh") == joinpath("zsh_dir", ".zshrc")
    end
end

end # TestBuilderInstall
