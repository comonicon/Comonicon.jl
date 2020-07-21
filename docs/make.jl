using Documenter, Comonicon

makedocs(;
    modules = [Comonicon],
    format = Documenter.HTML(prettyurls = !("local" in ARGS)),
    pages = ["Home" => "index.md"],
    repo = "https://github.com/Roger-luo/Comonicon.jl",
    sitename = "Comonicon.jl",
)

deploydocs(; repo = "github.com/Roger-luo/Comonicon.jl")
