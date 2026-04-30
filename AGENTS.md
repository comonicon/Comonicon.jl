# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Comonicon is a Julia CLI generator that transforms function definitions and docstrings into full-featured command-line interfaces with zero duplication, zero overhead, and zero dependencies. The two primary user-facing macros are `@cast` (mark a function/module as a CLI command) and `@main` (declare the CLI entry point).

## Build & Test Commands

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'   # Install dependencies
julia --project test/runtests.jl                     # Run all tests
julia --project -e 'using Pkg; Pkg.test()'           # Run tests via Pkg
```

To run a single testset:
```bash
julia --project -e 'using Test; include("test/runtests.jl")' # all
# Run a specific file directly (most test files are self-contained):
julia --project test/options.jl
julia --project test/frontend/cast.jl
```

## Pre-commit Checklist

```bash
julia --project -e 'using JuliaFormatter; format("src")'  # Format (margin=102)
julia --project test/runtests.jl                           # Tests
```

JuliaFormatter config: `always_for_in=true`, `margin=102`.

## Architecture

The pipeline is: **Julia source → Frontend (parse) → AST → Codegen → executable CLI**.

### Modules

| Module | Path | Role |
|--------|------|------|
| Frontend | `src/frontend/` | `@cast`/`@main` macros; parse function signatures and markdown docstrings into CLI metadata |
| AST | `src/ast/` | Immutable command-tree types: `Entry → NodeCommand/LeafCommand → Argument/Option/Flag` |
| Codegen | `src/codegen/` | `emit()` converts `Entry` to Julia `Expr`; also generates bash/zsh completions |
| Builder | `src/builder/` | Compilation, installation, system image generation via PackageCompiler |

### Key Types (`src/ast/types.jl`)

```
Entry
  └─ root: Union{NodeCommand, LeafCommand}
       ├─ NodeCommand  — routing node; holds OrderedDict of subcommands
       └─ LeafCommand  — executable leaf; holds Vector[Argument], OrderedDict[Option/Flag]
```

`Description`, `Argument`, `Option`, `Flag` all carry a `Description` (brief + long form). `LeafCommand.fn` is the wrapped Julia function.

### Special Types (`src/argtypes.jl`)

`Path`, `FileName`, `DirName`, `Prefix{name}`, `Suffix{name}` — used in function signatures to enable shell-completion hints and input validation.

### Codegen Entry Point

`emit(entry::Entry)` in `src/codegen/julia.jl` is the main code generation function. It recursively walks the command tree and produces a precompilable `command_main(::Vector{String})` function.

### Configuration (`src/configs.jl`)

TOML-based config via `Configurations.jl`. Types: `Install`, `Precompile`, `SysImg`. Stored in `Comonicon.toml` within a project.

## Key Conventions

- **Conventional commits:** `feat:`, `fix:`, `docs:`, `test:`, `ci:`, `refactor:`, `perf:`, `build:`, `chore:`
- **Breaking changes:** Use `feat!:` or `fix!:` (note the `!`) or add a `BREAKING CHANGE:` footer
- Tests mirror the `src/` structure: `test/frontend/`, `test/ast/`, `test/codegen/`, etc.
- The `test/scripts/` directory contains example CLI scripts used as integration tests.
