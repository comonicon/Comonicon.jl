using Test
using Pkg
using Comonicon

@static if VERSION < v"1.7-"
    """
        pkgdir(m, xs...)
    Return the subdirs in given root of module `m`.
    """
    function Base.pkgdir(m::Module, x, xs...)
        dir = pkgdir(m)
        dir === nothing && return
        return joinpath(dir, x, xs...)
    end
end

Pkg.activate(pkgdir(Comonicon, "test", "projects", "Hello"))
Pkg.develop(path=pkgdir(Comonicon))
Pkg.test()

Pkg.activate(pkgdir(Comonicon, "test", "projects", "FakePkg"))
Pkg.develop(path=pkgdir(Comonicon))
Pkg.test()
