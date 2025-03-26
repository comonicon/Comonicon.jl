using Documenter
using Comonicon
using DocThemeIndigo
using Documenter.Remotes: GitHub

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
    repo = GitHub("comonicon/Comonicon.jl"),
    sitename = "Comonicon.jl",
    checkdocs = :export,
)

deploydocs(; repo = "github.com/comonicon/Comonicon.jl")
