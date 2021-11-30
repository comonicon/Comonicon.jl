# Parse

This is the frontend `@cast` and `@main` of [`Comonicon`](@ref).

The `@main` command will use generate a few functions in the module:

1. the entry function for CLI `command_main`.
2. `comonicon_install`: for command build and installation.
3. `comonicon_build`: for CLI interface of build and installation.
3. `comonicon_install_path`: for path build and installation.
4. `julia_main`: for building standalone applications.

## References

```@autodocs
Modules = [Comonicon]
```
