"""
    get_version(m::Module)

Get the version of a given module. It will try to find the version
of `Project.toml` if the given module is a project module. If fails,
it returns `v"0.0.0"`.
"""
function get_version(m::Module)
    # no version for scripts
    m === Main && return
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
    return
end

"""
    set_cmd!(cmds::Dict, cmd)

register `cmd` in the command registry `cmds`, which usually is
a constant `CASTED_COMMANDS` under given module.
"""
function set_cmd!(cmds::Dict, cmd, name = cmd_name(cmd))
    if haskey(cmds, name)
        @warn "replacing command $name in the registry"
    end

    return cmds[name] = cmd
end

"""
    default_name(x::String)

Return the lowercase of a given package name. It will
ignore the suffix if it ends with ".jl".
"""
function default_name(x::String)
    if endswith(x, ".jl")
        name = x[1:end-3]
    else
        name = x
    end
    return replace(lowercase(name), '_'=>'-')
end

default_name(x::Symbol) = default_name(string(x))
