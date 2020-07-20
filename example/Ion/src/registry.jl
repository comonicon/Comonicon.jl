"""
registry tools
"""
module Registry

using Comonicon
using Pkg

"""
add a registry

# Arguments

- `url`: URL to the registry, or use name "General" to add the default general registry.
"""
@cast function add(url::String)
    Pkg.Registry.add(url)
end

end

@cast Registry
