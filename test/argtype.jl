using Test
using Comonicon: Arg

@testset "tryparse(::ArgType, s)" begin
    @test tryparse(Arg.Path, "random-string").content == "random-string"
    @test tryparse(Arg.Prefix"file-", "file-content").content == "content"
    @test tryparse(Arg.Suffix".py", "script.py").content == "script"
end
