default_name(x) = lowercase(string(nameof(x)))

function docstring(x)
    return sprint(@doc(x); context = :color => true) do io, x
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

    return Expr(:call, ref, params, xs...)
end

function get_version(m::Module)
    # project module
    path = pathof(m)
    if path !== nothing
        envpath = joinpath(dirname(path), "..")
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

function cachefile(file=Base.PROGRAM_FILE)
    dir = cachedir(file)
    return joinpath(dir, "cmd.jl"), joinpath(dir, "checksum")
end

function cachedir(file=Base.PROGRAM_FILE)
    name, _ = splitext(basename(file))
    dir = joinpath(dirname(file), "." * name * ".cmd")
    isabspath(file) || return joinpath(pwd(), dir)
    return dir
end

function iscached(file=Base.PROGRAM_FILE)
    cache_file, crc = cachefile(file)
    isfile(crc) || return false
    isfile(cache_file) || return false
    if read(crc, String) == string(checksum(file), base=16)
        return true
    end
    return false
end

# taken from Steven G Johnson
function checksum(filename, blocksize=16384)
    crc = zero(UInt32)
    open(filename, "r") do f
        while !eof(f)
            crc = crc32c(read(f, blocksize), crc)
        end
    end
    return crc
end

function create_cache(cmd, file=Base.PROGRAM_FILE)
    isempty(file) && return
    dir = cachedir(file)
    if !ispath(dir)
        mkpath(dir)
    end

    cache_file, crc = cachefile(file)
    write(cache_file, cmd)
    write(crc, string(checksum(file), base=16))
    return
end
