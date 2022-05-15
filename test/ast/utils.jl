using Test
using Faker
using Comonicon.AST

@testset "content_brief" begin
    for _ in 1:10
        @test length(AST.content_brief(Faker.text(); max_width=80)) ≤ 80
    end
end
