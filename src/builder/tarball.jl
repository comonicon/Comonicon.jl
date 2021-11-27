function tarball_name(m::Module, name::String, postfix = "sysimg")
    return "$name-$postfix-$(Comonicon.get_version(m))-julia-$VERSION-$(osname())-$(Sys.ARCH).tar.gz"
end

"""
    osname()

Return the name of OS, will be used in building tarball.
"""
function osname()
    return Sys.isapple() ? "darwin" :
           Sys.islinux() ? "linux" :
           error("unsupported OS, please open an issue to request support at $COMONICON_URL")
end

function pack_tarball(tarball::String, root::String, path::String)
    cd(root) do
        run(`tar -czvf $tarball $path`)
    end
end
