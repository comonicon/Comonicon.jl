"""
All the terminals are under my command. `Comonicon` is a CLI (Command Line Interface) generator
that features light-weight dependency (optional to have zero dependency),
fast start-up time and easy to use. See the [website](https://comonicon.rogerluo.dev)
for more info.
"""
module Comonicon

using Pkg
using Markdown
using ExproniconLite
using ComoniconTypes
using ComoniconOptions
using ComoniconBuilder
using ComoniconTargetExpr
using ComoniconZSHCompletion

export JLArgument, JLOption, JLFlag, JLMD, JLMDFlag, JLMDOption,
    @cast, @main, cast, cast_args, cast_flags, cast_options, default_name,
    get_version, split_leaf_command, split_docstring, read_arguments, read_description,
    read_options, read_flags, split_hint, split_option

include("types.jl")
include("cast.jl")
include("markdown.jl")
include("utils.jl")

end # module
