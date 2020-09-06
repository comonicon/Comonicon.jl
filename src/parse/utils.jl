"""
    default_name(x)

Return the lowercase of `nameof(x)` in `String`.
"""
default_name(x) = lowercase(string(nameof(x)))

"""
    default_name(x)

Return the lowercase of a given package name. It will
ignore the suffix if it ends with ".jl".
"""
function default_name(x::String)
    if endswith(x, ".jl")
        name = x[1:end-3]
    else
        name = x
    end
    return lowercase(name)
end

function docstring(x)
    return sprint(Base.Docs.doc(x); context = :color => true) do io, x
        show(io, MIME"text/plain"(), x)
    end
end

xcall(m::Module, name::Function, xs...; kwargs...) = xcall(m, nameof(name), xs...; kwargs...)
xcall(m::Module, name::Symbol, xs...; kwargs...) = xcall(GlobalRef(m, name), xs...; kwargs...)
xcall(name, xs...; kwargs...) = xcall(Parse, name, xs...; kwargs...)

function xcall(ref::GlobalRef, xs...; kwargs...)
    params = Expr(:parameters)
    for (key, value) in kwargs
        push!(params.args, Expr(:kw, key, value))
    end

    if isempty(kwargs)
        Expr(:call, ref, xs...)
    else
        return Expr(:call, ref, params, xs...)
    end
end

"""
    get_version(m::Module)

Get the version of a given module. It will try to find the version
of `Project.toml` if the given module is a project module. If fails,
it returns `v"0.0.0"`.
"""
function get_version(m::Module)
    # no version for scripts
    m === Main && return v"0.0.0"
    # project module
    path = pathof(m)
    if path !== nothing
        envpath = dirname(dirname(path))
        project = Pkg.Types.read_project(Pkg.Types.projectfile_path(envpath))
        if project.name == string(nameof(m)) && project.version !== nothing
            return project.version
        end
    end

    if hasproperty(m, :COMMAND_VERSION)
        return m.COMMAND_VERSION
    end
    return v"0.0.0"
end

"""
    cache_file([file=Base.PROGRAM_FILE])

Return the files that will be cached:

1. `cmd.jl`: a julia script that contains the generated CLI code.
2. `checksum`: a checksum file for checking if the generated CLI code matches the original file.
"""
function cachefile(file = Base.PROGRAM_FILE)
    dir = cachedir(file)
    return joinpath(dir, "cmd.jl"), joinpath(dir, "checksum")
end

"""
    cachedir([file=Base.PROGRAM_FILE])

Return the cache directory.
"""
function cachedir(file = Base.PROGRAM_FILE)
    name, _ = splitext(basename(file))
    dir = joinpath(dirname(file), "." * name * ".cmd")
    isabspath(file) || return joinpath(pwd(), dir)
    return dir
end

"""
    iscached([file=Base.PROGRAM_FILE])

Check if the given file is cached or not.
"""
function iscached(file = Base.PROGRAM_FILE)
    cache_file, crc = cachefile(file)
    isfile(crc) || return false
    isfile(cache_file) || return false
    if read(crc, String) == string(checksum(file), base = 16)
        return true
    end
    return false
end

# taken from Steven G Johnson
function checksum(filename, blocksize = 16384)
    crc = zero(UInt32)
    open(filename, "r") do f
        while !eof(f)
            crc = crc32c(read(f, blocksize), crc)
        end
    end
    return crc
end

"""
    create_cache(cmd[, file=Base.PROGRAM_FILE])

Create cache for given command `cmd` at file location `file`.
"""
function create_cache(cmd, file = Base.PROGRAM_FILE)
    isempty(file) && return
    dir = cachedir(file)
    if !ispath(dir)
        mkpath(dir)
    end

    cache_file, crc = cachefile(file)
    write(cache_file, cmd)
    write(crc, string(checksum(file), base = 16))
    return
end

"""
    valid_default_value(default)

Check if default value is valid.

If it is valid, the default value is returned.
Otherwise, it raises an error.
"""
function validate_default_value(default)
    if valid_default_value(default)
        return default
    end
    error("Default value $default is not valid")
end

"""
    valid_default_value(default)

Check if default value contains variable.
"""
function valid_default_value(default::Union{Number, String, Char})
    true
end

function valid_default_value(default::Expr)
    if default.head == :call
        args = default.args[2:end]
    else
        args = default.args
    end
    for arg in args
        if ~valid_default_value(arg)
            return false
        end
    end
    return true
end

function valid_default_value(default::Symbol)
    false
end
