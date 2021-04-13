"""
All the terminals are under my command. `Comonicon` is a CLI (Command Line Interface) generator
that features light-weight dependency (optional to have zero dependency),
fast start-up time and easy to use. See the [website](https://comonicon.rogerluo.dev)
for more info.
"""
module Comonicon

include("options.jl")
include("ir/ir.jl")
include("runtime.jl")

include("frontend/fontend.jl")
using .Frontend: @cast, @main
export @cast, @main
# include("codegen/ast.jl")

# using Markdown
# using Pkg
# using Libdl
# using ExprTools
# using Crayons.Box

# export @asset_str

# include("path.jl")
# include("assets.jl")
# include("options.jl")
# include("types.jl")
# include("codegen/codegen.jl")
# include("parse/parse.jl")

# export @cast, @main

# using .Options
# using .Types
# using .Parse
# using .CodeGen

# include("tools/tools.jl")
# include("tools/build.jl")

# using .BuildTools

# include("precompile.jl")
# _precompile_()

end # module
