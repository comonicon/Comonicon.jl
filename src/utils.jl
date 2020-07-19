regex_flag(x) = Regex("^--$(cmd_name(x))\$")
short_regex_flag(x) = Regex("^-$(first(cmd_name(x)))\$")

function rm_lineinfo(ex)
    if ex isa Expr
        args = []
        for each in ex.args
            if !(each isa LineNumberNode)
                push!(args, rm_lineinfo(each))
            end
        end
        return Expr(ex.head, args...)
    else
        return ex
    end
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
