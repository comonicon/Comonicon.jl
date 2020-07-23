module Comonicon

export print_cmd, codegen, install, cast_m, parse_doc, command, rm_lineinfo
export Arg, Flag, Option, NodeCommand, LeafCommand, EntryCommand
export @cast, @command_main

using Markdown
using Pkg
using Libdl
using ExprTools
using PackageCompiler

include("command.jl")
include("utils.jl")

include("codegen.jl")
include("build.jl")
include("printings.jl")
include("markdown.jl")
include("parse.jl")
include("validate.jl")

function main(m::Module = Main; name = default_name(m), doc = "", version = get_version(m))
    cmd = NodeCommand(name, collect(values(m.CASTED_COMMANDS)), doc)
    return EntryCommand(cmd; version = version)
end

include("precompile.jl")
_precompile_()

end # module
