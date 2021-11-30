using Test
using Scratch
using Comonicon.Options
using Comonicon.Builder: ensure_path, detect_shell, entryfile_script, completion_script

@testset "ensure_path" begin
    path = tempname()
    @test ispath(path) == false
    ensure_path(path)
    @test ispath(path) == true
end

@testset "detect_shell" begin
    withenv("SHELL" => "/bin/bash") do
        @test detect_shell() == "bash"
    end

    withenv("SHELL" => "/bin/zsh") do
        @test detect_shell() == "zsh"
    end
end

module TestInstall

using Comonicon

@cast foo(x) = 0
@cast goo(x) = 1

@main

end

@testset "entryfile_script" begin
    options = Options.Comonicon(name = "test")
    script = entryfile_script(TestInstall, options)

    @test occursin("#!/usr/bin/env sh", script)
    @test occursin("JULIA_PROJECT=$(get_scratch!(TestInstall, "env"))", script)
    julia_exe = joinpath(Sys.BINDIR, Base.julia_exename())
    @test occursin("exec $julia_exe \\\n", script)
    @test occursin("--startup-file=no \\\n", script)
    @test occursin("--color=yes \\\n", script)
    @test occursin("--compile=yes \\\n", script)
    @test occursin("--optimize=2 \\\n", script)
    @test occursin("-- \"\${BASH_SOURCE[0]}\"", script)
    @test occursin("using Main.TestInstall\nexit(Main.TestInstall.command_main())", script)
end

@testset "test completion script" begin
    withenv("SHELL" => "/bin/zsh") do
        script = completion_script(TestInstall, options)
        @test occursin("#compdef _testinstall testinstall \n", script)
    end

    withenv("SHELL" => "/bin/fakesh") do
        @test_throws ErrorException completion_script(TestInstall, options)
    end
end
