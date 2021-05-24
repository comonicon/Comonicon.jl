using Documenter, Comonicon

makedocs(;
    modules = [Comonicon, Comonicon.Parse, Comonicon.CodeGen],
    format = Documenter.HTML(prettyurls = !("local" in ARGS)),
    pages = [
        "Home" => "index.md",
        "Conventions" => "conventions.md",
        "Create a CLI project" => "project.md",
        "Command Types" => "types.md",
        "Command Parsing" => "parse.md",
        "Command Configuration" => "configurations.md",
        "Code Generation" => "codegen.md",
        "Build and Install CLI" => "build.md",
    ],
    repo = "https://github.com/comonicon/Comonicon.jl",
    sitename = "Comonicon.jl",
)

deploydocs(; repo = "github.com/comonicon/Comonicon.jl")
