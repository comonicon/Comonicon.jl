function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.precompile(Tuple{
        Core.kwftype(typeof(Comonicon.Type)),
        NamedTuple{
            (:name, :args, :options, :flags, :doc),
            Tuple{String,Array{Arg,1},Array{Any,1},Array{Any,1},String},
        },
        Type{LeafCommand},
        Function,
    })
    Base.precompile(Tuple{Type{EntryCommand},LeafCommand})
    Base.precompile(Tuple{typeof(Comonicon.command_main_m),Module,Expr})
    Base.precompile(Tuple{
        typeof(command),
        Function,
        Array{Tuple{String,DataType},1},
        Array{Tuple{String,DataType,Bool},1},
    })
end
