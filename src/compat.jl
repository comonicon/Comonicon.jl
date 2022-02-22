@static if VERSION < v"1.7"
    function Base.pkgdir(m::Module, path_::String, paths...)
        joinpath(pkgdir(m), path_, paths...)
    end
end

function _sprint(f, args...; color::Bool, displaysize=(24, 80))
    buf = IOBuffer()
    io = IOContext(buf, :color => color, :displaysize => displaysize)
    f(io, args...)
    return String(take!(buf))
end
