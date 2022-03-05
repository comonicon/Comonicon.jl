module Arg

export FileName, DirName, UserName, Path, Prefix, Suffix, @Prefix_str, @Suffix_str

abstract type ArgType end

struct Path <: ArgType
    content::String
end

struct DirName <: ArgType
    content::String
end

struct FileName <: ArgType
    content::String
end

struct UserName <: ArgType
    content::String
end

struct Prefix{name} <: ArgType
    content::String
end

struct Suffix{name} <: ArgType
    content::String
end

macro Prefix_str(s::String)
    return Prefix{Symbol(s)}
end

macro Suffix_str(s::String)
    return Suffix{Symbol(s)}
end

Base.show(io::IO, x::Prefix{name}) where {name} = print(io, "Prefix\"", name, "\"")
Base.show(io::IO, x::Suffix{name}) where {name} = print(io, "Suffix\"", name, "\"")

# use rust-like enum instead?
# @renum ArgType begin
#     Path
#     DirName
#     FileName
#     UserName
#     Prefix(name::String)
#     AnyType(name::String)
# end

function Base.tryparse(::Type{T}, s::AbstractString) where {T<:ArgType}
    return T(s)
end

function Base.tryparse(::Type{Prefix{name}}, s::AbstractString) where {name}
    prefix = string(name)
    startswith(s, prefix) && return Prefix{name}(s[length(prefix)+1:end])
    return
end

function Base.tryparse(::Type{Suffix{name}}, s::AbstractString) where {name}
    suffix = string(name)
    endswith(s, suffix) && return Suffix{name}(s[1:end-length(suffix)])
    return
end

end
