# AGENTS.md

This file provides guidance when working with code in this repository.

## Project

<!-- Describe your project here -->

## Build & Test Commands

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'  # Install dependencies
julia --project -e 'using Pkg; Pkg.test()'          # All tests
julia --project -e 'include("test/runtests.jl")'    # Run tests directly
```

## Pre-commit Checklist

**Run before committing:**

```bash
julia --project -e 'using JuliaFormatter; format("src")' # 1. Format
julia --project -e 'using Pkg; Pkg.test()'                # 2. Test
```

## Project Structure

- `Project.toml` -- project metadata and direct dependencies
- `Manifest.toml` -- locked dependency versions
- `src/` -- source code (main module file: `src/<PackageName>.jl`)
- `test/` -- test files (`test/runtests.jl` is the entry point)

## Architecture

<!-- Describe your architecture here. Examples: -->
<!-- - Module organization and exports -->
<!-- - Key types and their relationships -->
<!-- - Abstract types and their subtypes -->
<!-- - Multiple dispatch patterns -->

## Key Conventions

- **Module structure:** One main module matching the package name, with sub-modules in `src/`
- **Testing:** Tests live in `test/runtests.jl`, using the `Test` standard library
- **Documentation:** Use docstrings above functions/types with triple-quoted strings

## Git Conventions

- **Conventional commits:** `feat:`, `fix:`, `docs:`, `test:`, `ci:`, `refactor:`, `perf:`, `build:`, `chore:`
- **Breaking changes:** Use `feat!:` or `fix!:` (note the `!`) or add a `BREAKING CHANGE:` footer
