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
