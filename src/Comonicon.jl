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
using ComoniconTypes
using ComoniconOptions
using ComoniconTargetExpr
using ComoniconZSHCompletion

export @cast, @main, write_cmd

include("types.jl")
include("cast.jl")
include("markdown.jl")
include("utils.jl")

end # module
