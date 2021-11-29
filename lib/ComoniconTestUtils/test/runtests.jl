using Random
using Comonicon.AST
using ComoniconTestUtils
using Test

Random.seed!(42)

@testset "ComoniconTestUtils.jl" begin
    ComoniconTestUtils.test_function("a", "b", "c"; option_a=1, option_b=2)
    @test_args ["a", "b", "c"]
    @test_kwargs [:option_a=>1, :option_b=>2]    
end


find_leaf(cmd::Entry, inputs, current=1) = find_leaf(cmd.root, inputs, current)
find_leaf(cmd::LeafCommand, inputs, current=1) = cmd

function find_leaf(cmd::NodeCommand, inputs, current=1)
    @test haskey(cmd.subcmds, inputs[current])
    return find_leaf(cmd.subcmds[inputs[current]], inputs, current+1)
end

@testset "random_command + random_input" begin
    for _ in 1:10
        cmd = rand_command()
        inputs = rand_input(cmd)
        leaf = find_leaf(cmd, inputs)

        for each in inputs
            if startswith(each, "--")
                name = first(split(each, '='))
                name = lstrip(name, '-')
                @test haskey(leaf.options, name) || haskey(leaf.flags, name)
            end
        end
    end
end
