# Build and Install Tools

You can use various way to build and install your CLI, this includes:

- use it as a script, and enable or disable compile cache via (`Comonicon.disable_cache` and `Comonicon.enable_cache`).
- build it as a package and install to `~/.julia/bin`:
  - use `compile=:min` in `Comonicon.install` if you don't care about the speed
  - use `sysimg=true` in `Comonicon.install` if you care about both start up time and the speed

## Reference

```@autodocs
Modules = [Comonicon.Builder]
```
