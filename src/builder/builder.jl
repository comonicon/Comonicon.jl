module Builder

using ..Configs: Configs
using ..ZSHCompletions
using ..Comonicon: get_version, Tools
using PackageCompiler
using Logging
using TOML: TOML
using Libdl: Libdl
using Pkg: Pkg
using UUIDs: UUID
using Scratch: get_scratch!

const COMONICON_URL = "https://github.com/comonicon/Comonicon.jl"

include("cli.jl")
include("install.jl")
include("sysimg.jl")
include("app.jl")
include("tarball.jl")
include("rcfile.jl")

end
