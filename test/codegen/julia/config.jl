module TestConfigOption

using Test
using Comonicon
using Configurations

@option struct OptionA
    a::Int
    b::Int
end

@option struct OptionB
    option::OptionA
    c::Int
end

"""
# Options

- `-c, --config <path/to/option/or/specific field>`: config.
"""
@main function run(;config::OptionB)
    @test config == OptionB(OptionA(1, 1), 1)
end

@testset "config options" begin
    TestConfigOption.command_main(["--config.c=1", "--config.option.a=1", "--config.option.b=1"])

    opt = TestConfigOption.OptionB(TestConfigOption.OptionA(1, 1), 1)
    to_toml("config.toml", opt)
    TestConfigOption.command_main(["--config", "config.toml"])
    TestConfigOption.command_main(["-c", "config.toml"])

    opt = TestConfigOption.OptionB(TestConfigOption.OptionA(1, 1), 2)
    to_toml("config.toml", opt)
    TestConfigOption.command_main(["--config", "config.toml", "--config.c=1"])
end

end
