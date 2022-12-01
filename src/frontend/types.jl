Base.@kwdef struct JLArgument
    name::Symbol
    type::Any = Any
    require::Bool = true
    vararg::Bool = false
    default::Maybe{String} = nothing
end

struct JLOption
    name::Symbol
    require::Bool
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
    intro::String = ""
    arguments::OrderedDict{String,String} = OrderedDict{String,String}()
    options::OrderedDict{String,JLMDOption} = OrderedDict{String,JLMDOption}()
    flags::OrderedDict{String,JLMDFlag} = OrderedDict{String,JLMDFlag}()
end
