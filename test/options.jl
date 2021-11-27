using Test
using Comonicon.Options

@testset "load options" begin
    options = read_options(pkgdir(Comonicon, "test"))
    display(options)
    @test options == Options.Comonicon(;
        name = "foo",
        install = Options.Install(;
            compile = "min",
        ),
        sysimg = Options.SysImg(;
            cpu_target = "native",
            precompile = Options.Precompile(;
                execution_file = ["deps/precopmile.jl"],
            ),
        ),
        download = Options.Download(;
            user = "Roger-luo",
            repo = "Foo.jl",
        ),
        application = Options.Application(;
            assets = Options.Asset[asset"PkgTemplate: templates", asset"assets/images"],
            incremental = true,
            filter_stdlibs = false,
        ),
    )
end

@testset "has_comonicon_toml" begin
    @test Options.has_comonicon_toml(Main) == false
end
