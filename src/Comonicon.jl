"""
All the terminals are under my command. `Comonicon` is a CLI (Command Line Interface) generator
that features light-weight dependency (optional to have zero dependency),
fast start-up time and easy to use. See the [website](https://rogerluo.me/Comonicon.jl/)
for more info.
"""
module Comonicon

# export print_cmd, codegen, install, cast_m, parse_doc, command, rm_lineinfo
# export Arg, Flag, Option, NodeCommand, LeafCommand, EntryCommand
@static if VERSION > v"1.5.0-"
    Base.Experimental.@optlevel 0
end

using Markdown
using Pkg
using Libdl
using ExprTools
using PackageCompiler

include("types.jl")
include("codegen/codegen.jl")
include("parse/parse.jl")

export @cast, @main

using .Types
using .Parse
using .CodeGen

using .Parse: main

include("tools/tools.jl")
include("tools/path.jl")
include("tools/build.jl")

using .BuildTools

# include("build.jl")
# include("precompile.jl")
# _precompile_()

end # module
