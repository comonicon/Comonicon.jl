using Test
using Comonicon

Comonicon.@main function search(name)
    @test name == "Author - Year.pdf"
end
