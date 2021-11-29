using Test
using Comonicon
using Comonicon.Builder: contains_path, contains_fpath,
    write_path, write_fpath, detect_rcfile, install_env_path

home_dir = mktempdir()
test_dir = pkgdir(Comonicon, "test")
usr_dir = joinpath(test_dir, "usr")

options = Comonicon.Options.Comonicon(
    name="test",
    install=Comonicon.Options.Install(
        path=usr_dir,
        completion=false,
    ),
    sysimg=nothing,
)

@testset "contains path/write path" begin
    withenv("PATH"=>nothing, "FPATH"=>nothing) do
        dir = mktempdir()
        rcfile = joinpath(dir, ".bashrc")
        touch(rcfile)
        @test contains_path(rcfile, usr_dir, Base.EnvDict()) == false

        write_path(rcfile, usr_dir)
        @test contains_path(rcfile, usr_dir) == true

        @test contains_fpath(rcfile, usr_dir, Base.EnvDict()) == false

        write_fpath(rcfile, usr_dir)
        @test contains_fpath(rcfile, usr_dir) == true
    end

    withenv("PATH"=>joinpath(usr_dir, "bin"), "FPATH"=>joinpath(usr_dir, "completions")) do
        @test contains_path("rcfile", usr_dir) == true
        @test contains_fpath("rcfile", usr_dir) == true
    end
end

@testset "detect rcfile" begin
    @test detect_rcfile("zsh", home_dir) == joinpath(home_dir, ".zshrc")
    @test withenv("ZDOTDIR"=>"test") do
        detect_rcfile("zsh", home_dir)
    end == joinpath("test", ".zshrc")

    @test detect_rcfile("bash", home_dir) == joinpath(home_dir, ".bash_profile")
    touch(joinpath(home_dir, ".bashrc"))
    @test detect_rcfile("bash", home_dir) == joinpath(home_dir, ".bashrc")
end

@testset "install env path" begin
    install_env_path(Main, options; shell="zsh", home_dir, env=ENV, yes=true)

    withenv("PATH"=>nothing, "FPATH"=>nothing) do
        @test contains_path(joinpath(home_dir, ".zshrc"), usr_dir)
        @test contains_fpath(joinpath(home_dir, ".zshrc"), usr_dir)
    end
end
