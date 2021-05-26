module FakePkg

using Test
using Comonicon

"""
fake add

# Args

- `package`: package to add.
"""
@cast add(package) = @test package == "ABC"

"""
fake rm

# Args

- `package`: package to add.
"""
@cast rm(package) = @test package == "ABC"

"""
fake activate

# Args

- `env`: environment to activate.

# Flags

- `-s, --shared`: fake flag share.
"""
@cast function activate(env; shared::Bool=false)
    @test env == "fake"
    @test shared == true
end

include("registry.jl")

@main

end
