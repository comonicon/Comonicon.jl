module TestBuilderInstall

using Test
using Scratch
using Comonicon.Options
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
    options = Options.Comonicon(name = "test")
    script = entryfile_script(TestInstall, options)

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
        "using Main.TestBuilderInstall.TestInstall\nexit(Main.TestBuilderInstall.TestInstall.command_main())",
        script,
    )
end

@testset "test completion script" begin
    options = Options.Comonicon(name = "test")
    withenv("SHELL" => "/bin/zsh") do
        script = completion_script(TestInstall, options, "zsh")
        @test occursin("#compdef _testinstall testinstall \n", script)
    end

    withenv("SHELL" => "/bin/fakesh") do
        @test_throws ErrorException completion_script(TestInstall, options, "/bin/fakesh")
    end
end

@testset "detect_rcfile" begin
    withenv("SHELL" => "zsh") do
        @test detect_rcfile("zsh") == joinpath(homedir(), ".zshrc")
    end

    withenv("SHELL" => "zsh", "ZDOTDIR" => "zsh_dir") do
        @test detect_rcfile("zsh") == joinpath("zsh_dir", ".zshrc")
    end
end

end # TestBuilderInstall
