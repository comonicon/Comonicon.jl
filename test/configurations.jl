using Test
using Comonicon.PATH
using Comonicon.Configurations
using Comonicon.Configurations: Install, Application, SysImg, Download, Precompile

module XYZ end

@test read_configs(XYZ) == Configurations.Comonicon(
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

@test read_configs(XYZ; name = "zzz") == Configurations.Comonicon(
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

@test read_configs(XYZ; path = "mypath") == Configurations.Comonicon(
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

@test_throws ArgumentError read_configs(XYZ; filter_stdlibs = true)
@test_throws ArgumentError Application(; path = pwd())
@test_throws ArgumentError SysImg(; path = pwd())

read_configs(XYZ; user = "Roger-luo", repo = "Foo") == Configurations.Comonicon(
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

@test read_configs(PATH.project("test", "Foo", "Comonicon.toml")) == Configurations.Comonicon(
    name = "foo",
    install = Install(
        path = "~/.julia",
        completion = true,
        quiet = false,
        compile = "min",
        optimize = 2,
    ),
    sysimg = SysImg(
        path = "deps",
        incremental = true,
        filter_stdlibs = false,
        cpu_target = "native",
        precompile = Precompile(execution_file = ["deps/precopmile.jl"], statements_file = String[]),
    ),
    download = Download(host = "github.com", user = "Roger-luo", repo = "Foo.jl"),
    application = nothing,
)


@test_throws ErrorException read_configs(PATH.project("test"))
