Base.@kwdef struct JLArgument
    name::Symbol
    type::Any = Any
    require::Bool = true
    vararg::Bool = false
    default::Maybe{String} = nothing
end

struct JLOption
    name::Symbol
    type::Any
    hint::String
end

struct JLFlag
    name::Symbol
end

struct JLMDOption
    hint::Maybe{String}
    desc::String
    short::Bool
end

struct JLMDFlag
    desc::String
    short::Bool
end

Base.@kwdef struct JLMD
    desc::String = ""
    arguments::Dict{String, String} = Dict{String, String}()
    options::Dict{String, JLMDOption} = Dict{String, JLMDOption}()
    flags::Dict{String, JLMDFlag} = Dict{String, JLMDFlag}()
end
