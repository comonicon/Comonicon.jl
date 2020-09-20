"""
All the terminals are under my command. `Comonicon` is a CLI (Command Line Interface) generator
that features light-weight dependency (optional to have zero dependency),
fast start-up time and easy to use. See the [website](https://rogerluo.me/Comonicon.jl/)
for more info.
"""
module Comonicon

using Markdown
using Pkg
using Libdl
using ExprTools
using PackageCompiler

include("tools/path.jl")
include("configurations.jl")
include("types.jl")
include("codegen/codegen.jl")
include("parse/parse.jl")

export @cast, @main

using .Configurations
using .Types
using .Parse
using .CodeGen

include("tools/tools.jl")
include("tools/build.jl")

using .BuildTools

# include("precompile.jl")
# _precompile_()

end # module
