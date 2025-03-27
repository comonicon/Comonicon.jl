module TestConfigOption

using Test
using Comonicon
using Configurations

@option struct OptionA
    a::Int = 2
    b::Int = 2
end

@option struct OptionB
    option::OptionA
    c::Int
end

"""
# Options

- `-c, --config <path/to/option/or/specific field>`: config.
"""
@cast function run(; config::OptionB)
    @test config == OptionB(OptionA(1, 1), 1)
end

@cast function rundef(; config::OptionA = OptionA())
    @test config == OptionA(2, 2)
end

@main

@testset "config options" begin
    TestConfigOption.command_main([
        "run",
        "--config.c=1",
        "--config.option.a=1",
        "--config.option.b=1",
    ])

    opt = TestConfigOption.OptionB(TestConfigOption.OptionA(1, 1), 1)
    to_toml("config.toml", opt)
    TestConfigOption.command_main(["run", "--config", "config.toml"])
    TestConfigOption.command_main(["run", "-c", "config.toml"])

    opt = TestConfigOption.OptionB(TestConfigOption.OptionA(1, 1), 2)
    to_toml("config.toml", opt)
    TestConfigOption.command_main(["run", "--config", "config.toml", "--config.c=1"])

    TestConfigOption.command_main(["rundef"])
    TestConfigOption.command_main(["rundef", "--config.a=2"])
    TestConfigOption.command_main(["rundef", "--config.a=2", "--config.b=2"])
end

end
