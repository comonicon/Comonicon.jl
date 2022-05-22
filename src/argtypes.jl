module Arg

export FileName, DirName, UserName, Path, Prefix, Suffix, @Prefix_str, @Suffix_str

"""
    abstract type ArgType

Abstract type for special CLI arguments. These
types are useful for generating shell autocompletions
and argument checks. All the `ArgType` should implement
a corresponding `Base.tryparse` method, otherwise
it will fallback to passing the raw string as the `content`
field.
"""
abstract type ArgType end

"""
    struct Path <: ArgType
    Path(content)

A `Path` object denotes a path as CLI input.
"""
struct Path <: ArgType
    content::String
end

"""
    struct DirName <: ArgType
    DirName(content)

A `DirName` object denotes a directory name as CLI input.
"""
struct DirName <: ArgType
    content::String
end

"""
    struct FileName <: ArgType
    FileName(content)

A `FileName` object denotes a file name as CLI input.
"""
struct FileName <: ArgType
    content::String
end

"""
    struct UserName <: ArgType
    UserName(content)

A `UserName` object denotes a Linux/MacOS user name as CLI input.
"""
struct UserName <: ArgType
    content::String
end

"""
    struct Prefix{name} <: ArgType
    Prefix{name}(content)

Denotes strings with prefix `name` as CLI input, e.g `data-xxx`
"""
struct Prefix{name} <: ArgType
    content::String
end

"""
    struct Suffix{name} <: ArgType
    Suffix{name}(content)

Denotes strings with suffix `name` as CLI input, e.g `xxxxx.jl`.
"""
struct Suffix{name} <: ArgType
    content::String
end

"""
    macro Prefix_str
    Prefix"<name>"

Syntax sugar for creating a prefix type, e.g `Predix"data"`
is the same as `Prefix{:data}`.
"""
macro Prefix_str(s::String)
    return Prefix{Symbol(s)}
end

"""
    macro Suffix_str
    Suffix"<name>"

Syntax sugar for creating a suffix type, e.g `Suffix"data"`
is the same as `Suffix{:data}`.
"""
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
