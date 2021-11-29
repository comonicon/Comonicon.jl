using Comonicon.AST
using Test
using Faker

desc = Description(Faker.text())
@test endswith(desc.brief, ".") # brief should be a sentence

arg = Argument(;name="arg", type=Int)

macro test_show(mime, ex)
    Meta.isexpr(ex, :block) || error("expect begin ... end")
    ret = Expr(:block)
    for each in ex.args
        if Meta.isexpr(each, :call) && each.args[1] === :in
            @gensym buf object
            push!(ret.args, :($buf = IOBuffer()))
            push!(ret.args, :($object = $(each.args[3])))
            push!(ret.args, :(show($buf, $mime(), $object)))
            push!(ret.args, :(@test occursin($(each.args[2]), String(take!($buf)))))
        else
            push!(ret.args, each)
        end
    end
    return esc(ret)
end

@testset "convert(Description, ...)" begin
    @test Description(nothing) == Description()
    @test convert(Description, nothing) == Description()
    @test convert(Description, "nothing") == Description("nothing")
    @test convert(Description, split("abcd. efdasdas.", '.')[1]) == Description("abcd")
end

@test_show MIME"text/plain" begin
    "<arg>" in Argument(;name="arg")
    "[arg...]" in Argument(;name="arg", vararg=true)
    "<arg::Int64>" in Argument(;name="arg", type=Int)
    "--option-a" in Option(;sym=:option_a)
    "--option-a <hint>" in Option(;sym=:option_a, hint="hint")
    "--flag-a" in Flag(;sym=:flag_a)
end

leaf = LeafCommand(;
    fn=identity,
    name="leaf",
    args=[Argument(;name="arg", description=Faker.text())],
    flags=Dict(
        "flag-a" => Flag(;
            sym=:flag_a,
            description="flag a."
        ),
        "flag-b" => Flag(;
            sym=:flag_b,
            description="flag b."
        )
    ),
    description=Faker.text(),
)

@test_show MIME"text/plain" begin
    "  leaf <args> [options] [flags]" in leaf
    "Args\n\n" in leaf
    "  <arg>" in leaf
    "Flags\n\n" in leaf
end

@test_throws ErrorException NodeCommand(;name="abc", subcmds=Dict{String, Any}())


node = NodeCommand(;name="foo", subcmds=Dict("leaf"=>leaf))

@test_show MIME"text/plain" begin
    "  foo <command>" in node
    "Commands\n\n" in node
    "  leaf <arg>" in node
    "Flags\n\n" in node
    "-h, --help" in node
end
