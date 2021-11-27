"fake registry"
module Registry

using Test
using Comonicon

@cast add(path) = @test path === "abc"
@cast rm(path) = @test path === "abc"

end

@cast Registry
