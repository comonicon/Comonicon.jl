"""
All the terminals are under my command. `Comonicon` is a CLI (Command Line Interface) generator
that features light-weight dependency (optional to have zero dependency),
fast start-up time and easy to use. See the [website](https://comonicon.org)
for more info.
"""
module Comonicon

using Pkg
using Markdown
using ExproniconLite

export @cast, @main

include("compat.jl")
include("options.jl")
include("ast/ast.jl")
include("codegen/julia.jl")
include("codegen/zsh.jl")
include("tools.jl")

include("frontend/frontend.jl")
include("builder/builder.jl")

end # module
