module Issue218

using Test
using Comonicon

@cast function print(file)
    @show file
    if splitext(file)[2] == ".toml"
        print("hhhh")
    else
        # An intentional error
        error("my casted `print` is loaded!")
    end
end

@main

@testset "issue#128" begin
    @test Issue218.command_main(["-h"]) == 0
end

end
