using Documenter
using Comonicon
using DocThemeIndigo

indigo = DocThemeIndigo.install(Comonicon)

makedocs(;
    modules = [Comonicon],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        # canonical="https://comonicon.github.io/Configurations.jl",
        assets = String[indigo],
    ),
    pages = [
        "Home" => "index.md",
        "Syntax & Conventions" => "conventions.md",
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
