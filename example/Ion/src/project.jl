function project_path(path)
    if !isabspath(path)
        return joinpath(pwd(), path)
    else
        return path
    end
end

"""
create a project or package.

# Arguments

- `path`: path of the project you want to create

# Flags

- `-i, --interactive`: enable to start interactive configuration interface.
"""
@cast function create(path; interactive::Bool=false)
    fullpath = project_path(path)

    if ispath(fullpath)
        error("$path exists, remove it or use a new path")
    end

    if interactive
        t = Template(;dir=dirname(fullpath), interactive=true)
        t(basename(path))
    end

    # TODO: use .ionrc to save user configuration
    # and reuse it next time
    t = Template(;dir=dirname(fullpath))
    t(basename(path))
    return
end

function default_clone_name(url)
    name, _ = splitext(basename(url)) # rm .git
    _name, ext = splitext(name)
    if ext == ".jl" # preserve other extension
        name = _name
    end
    return name
end

"""
clone a package repo to a local directory.

# Arguments

- `url`: a remote or local url of the git repository.
- `to` : a local position, default to be the repository name (without .jl)

"""
@cast function clone(url, to=default_clone_name(url); credential="")
    LibGit2.clone(url, to)
    return
end

"""
add package/project to the closest project.

# Arguments

- `url`: package name or url to add.

# Options

- `-v, --version <version number>`: package version, default is the latest available version, or master branch for git repos.
- `--rev <branch/commit>`: git revision, can be branch name or commit hash.
- `-s, --subdir <subdir>`: subdir of the package.

# Flags

- `-g, --glob`: add package to global shared environment.

"""
@cast function add(url; version::String="", rev::String="", subdir::String="", glob::Bool=false)
    kwargs = []
    if isurl(url)
        push!(kwargs, "url=\"$url\"")
    else
        push!(kwargs, "name=\"$url\"")
    end

    !isempty(version) && push!(kwargs, "version=\"$version\"")
    !isempty(rev) && push!(kwargs, "rev=\"$rev\"")
    !isempty(subdir) && push!(kwargs, "subdir=\"$subdir\"")

    kw = join(kwargs, ", ")

    script = "using Pkg;"
    if !glob
        err_msg = "cannot install to global environment, use -g, --glob to install a package to global environment"
        script *= "(dirname(dirname(dirname(Pkg.project().path))) in DEPOT_PATH) && error(\"$err_msg\");"
    end

    script *= "Pkg.add(;$kw);"
    cmd = Cmd(["-e", script])

    if glob
        run(`$(Base.julia_cmd()) $cmd`)
    else
        withenv("JULIA_PROJECT"=>"@.") do
            run(`$(Base.julia_cmd()) $cmd`)
        end
    end
end

"""
Make a package available for development. If pkg is an existing local path, that path will be recorded in the manifest and used.
Otherwise, a full git clone of pkg is made. Unlike the `dev/develop` command in Julia REPL pkg mode, `ion` will clone the package
to the dev folder of the current project. You can specify `--shared` flag to use shared `dev` folder under `~/.julia/dev`
(specified by `JULIA_PKG_DEVDIR`).

# Arguments

- `url`: URL or local path to the package.

# Flags

- `-s, --shared`: controls whether to use the shared develop folder.

"""
@cast function dev(url; shared::Bool=false)
    shared_flag = shared ? "--shared" : "--local"
    cmd = Cmd(["-e", "using Pkg; pkg\"dev $shared_flag $url\" "])
    withenv("JULIA_PROJECT"=>"@.") do
        run(`$(Base.julia_cmd()) $cmd`)
    end
end

"""
Update a package. If no posistional argument is given, update all packages in current project.

# Arguments

- `pkg`: package name.
"""
@cast function update(pkg="")
    if isempty(pkg)
        cmd = Cmd(["-e", "using Pkg; pkg\"up\" "])
    else
        cmd = Cmd(["-e", "using Pkg; pkg\"up $pkg\" "])
    end
    withenv("JULIA_PROJECT"=>"@.") do
        run(`$(Base.julia_cmd()) $cmd`)
    end
end

@doc Docs.doc(update)
@cast up(pkg="") = update(pkg)

"""
"""
@cast function build(pkg=""; verbose::Bool=false)
end

# @cast function register()
# end
