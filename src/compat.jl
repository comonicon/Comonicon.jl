@static if VERSION < v"1.7"
    function Base.pkgdir(m::Module, path_::String, paths...)
        joinpath(pkgdir(m), path_, paths...)
    end
end
