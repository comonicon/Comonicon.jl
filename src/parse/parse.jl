module Parse

using ExprTools
using Markdown
using Pkg
using CRC32c
using MatchCore
using ..Comonicon
using ..Comonicon.Options
using ..Comonicon.Types
using ..Comonicon.CodeGen
using ..Comonicon.PATH: default_name

export @cast,
    @main,
    read_doc,
    command,
    rm_lineinfo,
    get_version,
    iscached,
    cachefile,
    create_cache,
    enable_cache,
    disable_cache

include("cast.jl")
include("markdown.jl")
include("runtime.jl")
include("utils.jl")

end
