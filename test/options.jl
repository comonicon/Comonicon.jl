using Test
using Comonicon
using Comonicon.Configs

@testset "load options" begin
    options = read_options(pkgdir(Comonicon, "test"))
    display(options)
    @test options == Configs.Comonicon(;
        name = "foo",
        install = Configs.Install(; compile = "min", nthreads="auto"),
        sysimg = Configs.SysImg(;
            cpu_target = "native",
            precompile = Configs.Precompile(; execution_file = ["deps/precopmile.jl"]),
        ),
        download = Configs.Download(; user = "Roger-luo", repo = "Foo.jl"),
        application = Configs.Application(;
            assets = Configs.Asset[asset"PkgTemplate: templates", asset"assets/images"],
            incremental = true,
            filter_stdlibs = false,
        ),
    )
end

@testset "has_comonicon_toml" begin
    @test Configs.has_comonicon_toml(Main) == false
end
