module Configurations

export read_configs

const COMONICON_TOML = ["Comonicon.toml", "JuliaComonicon.toml"]

using PackageCompiler
using Pkg.TOML
using ..Comonicon.PATH

"""
abstract type for Comonicon configurations.
"""
abstract type AbstractConfiguration end

"""
    Install <: AbstractConfiguration

Installation configurations.

## Keywords

- `path`: installation path.
- `completion`: set to `true` to install shell auto-completion scripts.
- `quiet`: print logs or not, default is `false`.
- `compile`: julia compiler option for CLIs if not built as standalone application, default is "min".
- `optimize`: julia compiler option for CLIs if not built as standalone application, default is `2`.
"""
Base.@kwdef struct Install <: AbstractConfiguration
    path::String="~/.julia"
    completion::Bool=true
    quiet::Bool=false
    compile::String="yes"
    optimize::Int=2
end

"""
    Precompile <: AbstractConfiguration

Precompilation files for `PackageCompiler`.

## Keywords

- `execution_file`: precompile execution file.
- `statements_file`: precompile statements file.
"""
Base.@kwdef struct Precompile <: AbstractConfiguration
    execution_file::Vector{String} = String[]
    statements_file::Vector{String} = String[]
end

"""
    SysImg <: AbstractConfiguration

System image build configurations.

## Keywords

- `path`: system image path to generate into, default is "deps/lib".
- `incremental`: set to `true` to build incrementally, default is `true`.
- `filter_stdlibs`: set to `true` to filter out unused stdlibs, default is `false`.
- `cpu_target`: cpu target to build, default is `PackageCompiler.default_app_cpu_target()`.
- `precompile`: precompile configurations, see [`Precompile`](@ref), default is `Precompile()`.
"""
Base.@kwdef struct SysImg <: AbstractConfiguration
    path::String="deps"
    incremental::Bool=true
    filter_stdlibs::Bool=false
    cpu_target::String=PackageCompiler.default_app_cpu_target()
    precompile::Precompile = Precompile()

    function SysImg(path::String, incremental::Bool, filter_stdlibs::Bool, cpu_target::String, precompile::Precompile)
        if isabspath(path)
            throw(ArgumentError("sysimg path must be project relative"))
        end
        new(path, incremental, filter_stdlibs, cpu_target, precompile)
    end
end

"""
    Download <: AbstractConfiguration

Download information.

## Keywords

- `host`: where are the tarballs hosted, default is "github.com"
- `user`: required, user name on the host.
- `repo`: required, repo name on the host.

!!! note
    Currently this only supports github, and this is considered experimental.
"""
Base.@kwdef struct Download <: AbstractConfiguration
    host::String="github.com"
    user::String
    repo::String
end

"""
    Application <: AbstractConfiguration

Application build configurations.

## Keywords

- `path`: application build path, default is "build".
- `incremental`: set to `true` to build incrementally, default is `true`.
- `filter_stdlibs`: set to `true` to filter out unused stdlibs, default is `false`.
- `cpu_target`: cpu target to build, default is `PackageCompiler.default_app_cpu_target()`.
- `precompile`: precompile configurations, see [`Precompile`](@ref), default is `Precompile()`.
"""
Base.@kwdef struct Application <: AbstractConfiguration
    path::String="build"
    incremental::Bool=false
    filter_stdlibs::Bool=true
    cpu_target::Bool=PackageCompiler.default_app_cpu_target()
    precompile::Precompile=Precompile()

    function Application(path::String, incremental::Bool, filter_stdlibs::Bool, cpu_target::Bool, precompile::Precompile)
        if isabspath(path)
            throw(ArgumentError("build path must be project relative"))
        end
        new(path, incremental, filter_stdlibs, cpu_target, precompile)
    end
end

Base.@kwdef struct Daemon <: AbstractConfiguration
end

"""
    Comonicon <: AbstractConfiguration

Build configurations for Comonicon. One can set this option
via `Comonicon.toml` under the root path of a Julia
project directory and read in using [`read_configs`](@ref).

## Keywords

- `name`: required, the name of CLI file to install.
- `install`: installation options, see also [`Install`](@ref).
- `sysimg`: system image build options, see also [`SysImg`](@ref).
- `download`: download options, see also [`Download`](@ref).
- `application`: application build options, see also [`Application`](@ref).
"""
Base.@kwdef struct Comonicon <: AbstractConfiguration
    name::String

    install::Install = Install()
    sysimg::Union{SysImg, Nothing} = nothing
    download::Union{Download, Nothing} = nothing
    application::Union{Application, Nothing} = nothing
end

function Base.show(io::IO, x::AbstractConfiguration)
    indent = get(io, :indent, 0)

    summary(io, x)
    println(io, "(")
    fnames = fieldnames(typeof(x))
    for each in fieldnames(typeof(x))
        inner_io = IOContext(io, :indent => indent+2)
        print(inner_io, " "^indent, " "^2, each, " = ")
        show(inner_io, getfield(x, each))
        println(inner_io, ", ")
    end
    print(io, " "^indent, ")")
    return
end

function _list_configurations(::Type{T}) where {T <: AbstractConfiguration}
    map(x->" "^2 * string(x), fieldnames(T))
end

function Comonicon(d::Dict{String})
    haskey(d, "name") || error("key \"name\" is missing in (Julia)Comonicon.toml")

    return Comonicon(;
        name = d["name"],
        install = haskey(d, "install") ? Install(d["install"]) : Install(),
        sysimg = haskey(d, "sysimg") ? SysImg(d["sysimg"]) : nothing,
        download = haskey(d, "download") ? Download(d["download"]) : nothing,
        application = haskey(d, "application") ? Application(d["application"]) : nothing,
    )
end

function _handle_precompile(d::Dict{String})
    return _to_kwargs(d) do k, v
        if k == "precompile"
            return Precompile(v)
        else
            return v
        end
    end
end

function _to_kwargs(f, d::Dict{String})
    kwargs = Dict{Symbol, Any}()
    for (k, v) in d
        kwargs[Symbol(k)] = f(k, v)
    end
    return kwargs
end

_to_kwargs(d::Dict{String}) = _to_kwargs((k,v)->v, d)

function SysImg(d::Dict{String})
    return SysImg(;_handle_precompile(d)...)
end

function Application(d::Dict{String})
    return Application(;_handle_precompile(d)...)
end

function (::Type{T})(d::Dict{String}) where {T <: AbstractConfiguration}
    return T(;_to_kwargs(d)...)
end

"""
    find_comonicon_toml(path::String)

Find `Comonicon.toml` or `JuliaComonicon.toml` in given path.
"""
function find_comonicon_toml(path::String)
    # user input file path
    basename(path) in COMONICON_TOML && return path
    
    # user input dir path
    for file in COMONICON_TOML
        path = joinpath(path, file)
        if ispath(path)
            return path
        end
    end
    return
end

"""
    read_toml(path::String)

Read `Comonicon.toml` or `JuliaComonicon.toml` in given path.
"""
function read_toml(path::String)
    file = find_comonicon_toml(path)
    file === nothing && return Dict{String, Any}()
    return TOML.parsefile(file)
end

"""
    read_toml(mod::Module)

Read `Comonicon.toml` or `JuliaComonicon.toml` in given module's project path.
"""
function read_toml(mod::Module)
    return read_toml(PATH.project(mod))
end

"""
    read_configs(comonicon; kwargs...)

Read in Comonicon build options. The argument `comonicon` can be:

- a module of a Comonicon CLI project.
- a path to a Comonicon CLI project that contains either `JuliaComonicon.toml` or `Comonicon.toml`.
- a path to a Comonicon CLI build configuration file named either `JuliaComonicon.toml` or `Comonicon.toml`.

In some cases, you might want to change the configuration written in the TOML file temporarily, e.g for writing
build tests etc. In this case, you can modify the configuration using corresponding keyword arguments.

keyword arguments of [`Application`](@ref) and [`SysImg`](@ref) are the same, thus keys like `filter_stdlibs`
are considered ambiguous in `read_configs`, but you can specifiy them by specifiy the specific [`Application`](@ref)
or [`SysImg`](@ref) object, e.g

```julia
read_configs(MyCLI; sysimg=SysImg(filter_stdlibs=false))
```

See also [`Comonicon`](@ref), [`Install`](@ref), [`SysImg`](@ref), [`Application`](@ref),
[`Download`](@ref), [`Precompile`](@ref).
"""
function read_configs(m::Union{Module, String}; kwargs...)
    configurations = read_toml(m)

    for (k, v) in kwargs
        if k in fieldnames(Comonicon)
            configurations[string(k)] = v
        elseif k in fieldnames(Install)
            option_install = get!(configurations, "install", Dict{String, Any}())
            option_install[string(k)] = v
        elseif k in fieldnames(Download)
            option_download = get!(configurations, "download", Dict{String, Any}())
            option_download[string(k)] = v
        elseif k in fieldnames(SysImg) || k in fieldnames(Application)
            throw(ArgumentError(
                "ambiguous option, please use SysImg/Application struct " *
                "with keyword \"sysimg\"/\"application\" to specifiy option \"$k\""
            ))
        else
            throw(ArgumentError("""
            unsupported kwargs $k, options are:
            $(join([
                "comonicon options:",
                _list_configurations(Comonicon)...,
                "",
                "install options:",
                _list_configurations(Install)...,
                "",
                "download options:",
                _list_configurations(Download)...,
            ], "\n"))
            """))
        end
    end

    if !haskey(configurations, "name")
        configurations["name"] = default_cmd_name(m)
    end

    return Comonicon(configurations)
end

default_cmd_name(m::Module) = lowercase(string(nameof(m)))
default_cmd_name(path::String) = lowercase(splitext(basename(path))[1])

end # Configs
