module CodeGen

using ExprTools
using MatchCore
using Comonicon.Types

export ASTCtx, ZSHCompletionCtx
export codegen, rm_lineinfo, prettify, pushmaybe!

include("utils.jl")
include("ast.jl")
include("completion.jl")

end
