using Comonicon

# pkg activate <string> --shared=false

module PkgCmd

using Comonicon

"""
activate the environment at `path`.


# Arguments

- `path`: the path of the environment

# Flags

- `--shared`: whether activate the shared environment
"""
@cast function activate(path; shared::Bool = false)
    println("activating $path (shared=$shared)")
end

Comonicon.@main

end

PkgCmd.command_main()
