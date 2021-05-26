using Test
using Comonicon

# pkg activate <string> --shared=false

module PkgCmd

using Test
using Comonicon

"""
activate the environment at `path`.


# Arguments

- `path`: the path of the environment

# Flags

- `--shared`: whether activate the shared environment
"""
@cast function activate(path; shared::Bool = false)
    @test path == "path"
    @test shared == true
end

@main

end

PkgCmd.command_main()
