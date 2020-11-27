struct Asset
    package::Union{Nothing, String}
    path::String
end

function Asset(s::String)
    parts = strip.(split(s, ":"))
    if length(parts) == 1
        Asset(nothing, parts[1])
    elseif length(parts) == 2
        Asset(parts[1], parts[2])
    else
        error("invalid syntax for asset string: $s")
    end
end

macro asset_str(s::String)
    return Asset(s)
end

function Base.show(io::IO, x::Asset)
    print(io, "asset\"")
    if x.package !== nothing
        print(io, GREEN_FG(x.package), ": ")
    end
    print(io, CYAN_FG(x.path), "\"")
end

Base.convert(::Type{Asset}, s::String) = Asset(s)
