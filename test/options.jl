using Test
using Comonicon.PATH
using Comonicon.Options
using Comonicon.Options: Install, Application, SysImg, Download, Precompile

module XYZ end

@test read_configs(XYZ) == Options.Comonicon(
    name = "xyz",
    install = Install(
        path = "~/.julia",
        completion = true,
        quiet = false,
        compile = "yes",
        optimize = 2,
    ),
    sysimg = nothing,
    download = nothing,
    application = nothing,
)

@test read_configs(XYZ; name = "zzz") == Options.Comonicon(
    name = "zzz",
    install = Install(
        path = "~/.julia",
        completion = true,
        quiet = false,
        compile = "yes",
        optimize = 2,
    ),
    sysimg = nothing,
    download = nothing,
    application = nothing,
)

@test read_configs(XYZ; install_path = "mypath") == Options.Comonicon(
    name = "xyz",
    install = Install(
        path = "mypath",
        completion = true,
        quiet = false,
        compile = "yes",
        optimize = 2,
    ),
    sysimg = nothing,
    download = nothing,
    application = nothing,
)

# @test_throws ArgumentError read_configs(XYZ; filter_stdlibs = true)
# @test_throws ArgumentError Application(; path = pwd())
# @test_throws ArgumentError SysImg(; path = pwd())

@test read_configs(XYZ; download_user = "Roger-luo", download_repo = "Foo") == Options.Comonicon(
    name = "xyz",
    install = Install(
        path = "~/.julia",
        completion = true,
        quiet = false,
        compile = "yes",
        optimize = 2,
    ),
    sysimg = nothing,
    download = Download(user = "Roger-luo", repo = "Foo"),
    application = nothing,
)

@test_throws ArgumentError read_configs(XYZ; abc = 2)
@test_throws ErrorException read_configs(PATH.project("test"))
