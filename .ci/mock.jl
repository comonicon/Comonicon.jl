using PackageCompiler
function PackageCompiler.create_sysimage(
    packages;
    sysimage_path::String,
    project::String = dirname(Base.active_project()),
    precompile_execution_file::Union{String,Vector{String}} = String[],
    precompile_statements_file::Union{String,Vector{String}} = String[],
    incremental::Bool = true,
    filter_stdlibs::Bool = false,
    cpu_target::String = NATIVE_CPU_TARGET,
    script::Union{Nothing,String} = nothing,
    sysimage_build_args::Cmd = ``,
    include_transitive_dependencies::Bool = true,
    # Internal args
    base_sysimage::Union{Nothing,String} = nothing,
    julia_init_c_file = nothing,
    version = nothing,
    soname = nothing,
    compat_level::String = "major",
)
    write(sysimage_path, "test")
    return
end
