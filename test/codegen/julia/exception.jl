using Test

module TestException

using Comonicon

@cast function throw_error()
    cmd_error("a command error thrown", 128)
end

@cast function throw_terminate()
    cmd_exit()
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
