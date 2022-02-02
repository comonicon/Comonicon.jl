using Test

module TestException

using Comonicon

@cast function throw_error()
    throw(CommandError("a command error thrown", 128))
end

@cast function throw_terminate()
    throw(CommandTerminate())
end

@cast function unhandled_error()
    error("unhandled")
end

@main

end

@testset "exception handling" begin
    @test TestException.command_main(["throw-error"]) == 128
    @test TestException.command_main(["throw-terminate"]) == 0
    @test_throws ErrorException TestException.command_main(["unhandled-error"])
end
