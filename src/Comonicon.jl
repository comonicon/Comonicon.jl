module Comonicon

# export print_cmd, codegen, install, cast_m, parse_doc, command, rm_lineinfo
# export Arg, Flag, Option, NodeCommand, LeafCommand, EntryCommand

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

include("build.jl")


# include("precompile.jl")
# _precompile_()

end # module
