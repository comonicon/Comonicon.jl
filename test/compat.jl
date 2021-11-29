using Test
using Comonicon: Comonicon, pkgdir

if VERSION < v"1.7"
    @testset "pkgdir" begin
        @test pkgdir(Comonicon, "test") == joinpath(pkgdir(Comonicon), "test")
    end
end
