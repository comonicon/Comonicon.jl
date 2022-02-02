using Test
using Comonicon
using Comonicon.Tools: prompt

@show Base.isinteractive()
@testset "prompt(msg) input=$yes" for yes in ['Y', 'y', '\n', '\r']
    print(stdin.buffer, yes)
    @test prompt("input something") == true
    readavailable(stdin.buffer)
end

@testset "prompt(msg) input=$no" for no in ['N', 'n', 'a', 'b']
    print(stdin.buffer, no)
    @test prompt("input something") == false
    readavailable(stdin.buffer)
end

@testset "prompt(msg;yes) input=$input" for input in
        ['Y', 'y', '\n', '\r','N', 'n', 'a', 'b']
    print(stdin.buffer, input)
    @test prompt("input something"; yes=true) == true
    readavailable(stdin.buffer)
end

@testset "prompt(msg; require=true)" begin
    print(stdin.buffer, '\n')
    print(stdin.buffer, '\n')
    print(stdin.buffer, 'Y')
    @test prompt("input something"; require=true) == true
    readavailable(stdin.buffer)

    print(stdin.buffer, '\n')
    print(stdin.buffer, '\n')
    print(stdin.buffer, 'n')
    @test prompt("input something"; require=true) == false
    readavailable(stdin.buffer)

    print(stdin.buffer, '\n')
    print(stdin.buffer, '\n')
    print(stdin.buffer, '\n')
    @test_throws Comonicon.CommandError prompt("input something"; require=true)
    readavailable(stdin.buffer)
end
