using Test
using Pkg
using Comonicon

Pkg.activate(pkgdir(Comonicon, "test", "projects", "Hello"))
Pkg.develop(path=pkgdir(Comonicon))
Pkg.test()

Pkg.activate(pkgdir(Comonicon, "test", "projects", "FakePkg"))
Pkg.develop(path=pkgdir(Comonicon))
Pkg.test()
