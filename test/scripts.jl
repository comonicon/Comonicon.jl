module TestScripts

using Test

@testset "scripts" begin
    empty!(ARGS)
    push!(ARGS, "arg", "--opt1=2", "--opt2", "3", "-f")
    Base.include(Main, "scripts/hello.jl")
    @test Main.command_main() == 0

    empty!(ARGS)
    push!(ARGS, "activate", "-h")
    @test Base.include(Main, "scripts/pkg.jl") == 0

    empty!(ARGS)
    push!(ARGS, "activate", "path", "--shared")
    @test Base.include(Main, "scripts/pkg.jl") == 0

    empty!(ARGS)
    push!(ARGS, "Author - Year.pdf")
    Base.include(Main, "scripts/searchpdf.jl")
    @test Main.command_main() == 0
end

end
