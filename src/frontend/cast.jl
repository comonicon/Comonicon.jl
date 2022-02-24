const MAIN_DOCSTRING = """
# CLI Definitions and Julia Syntax Mapping

**positional arguments** normal inputs, these are mapped as Julia function arguments, e.g

```shell
sum 1 2
```

`sum` is the command, and `1`, `2` are positional arguments.

**options** arguments with syntax `--<name>=<value>` or `--<name> <value>`,
these are mapped as Julia keyword arguments, e.g

```shell
sum --precision=float32 1 2
```

`--precision` is the option of command `sum` and has value `float32`.

**short options** arguments with syntax `-<letter>=<value>` or `-<letter><value>`
or `--<letter> <value>`, the letter is usually the first character of a normal
option, e.g

```shell
sum -pfloat32 1 2
```

`-p` is the same as `--precision`, but in short hand, this is enabled by writing
corresponding docstring (see the next section on docstring syntax).

**flags** like options, but without any value, e.g `--<name>`, this is mapped
to a special type of keyword argument that is of type `Bool` and has default value
`false`, e.g

```shell
sum --fastmath
```

**short flags** flags with syntax `-<letter>`, the letter should be the first character
of the corresponding normal flag, e.g

```shell
sum -f
```

# Doc String Syntax

Each different kind of inputs must have a different
level-1 section (markdown syntax `#<section name>`).

The docstring must have section name:

- `#Args` or `#Arguments` to declare the documentation
    of positional arguments.
- `#Options` to declare the documentation of options.
- `#Flags` to declare the documentation of flags.

# Examples

The simplest usage is creating the following commands

```julia
\"\"\"
an example command

# Args

- `x`: first argument
- `y`: second argument
- `z`: last argument

# Flags

- `-f, --flag`: a flag, optionally can be a short flag.

# Options

- `-o, --option=<int>`: an option, optionally can be short option.

\"\"\"
@cast function mycommand(x, y, z; flag::Bool=false, option::Int=2)
    # some implementation
    return
end

@cast function myothercommand(xs...)
    # another command with variatic arguments
    return
end

\"\"\"
My main command.
\"\"\"
@main # declare the entry
```

this can be used in command line as `mycommand 1 2 3 --flag`, you can
also just type `-h` to check the detailed help info.

The command line documentation will be generated automatically from
your Julia docstring.

If you have deeper hierachy of commands, you can also put `@cast`
on a Julia module.

```julia
using Comonicon
@cast module NodeCommand

using Comonicon

@cast module NodeSubCommand
using Comonicon
@cast bar(x) = println("bar $x")
end
@cast foo(x) = println("foo $x")
@main
end

NodeCommand.command_main()
```

"""

# ---------

"""
    @cast <function definition>
    @cast <module definition>

Denote a Julia expression is a command. If the expression
is a function definition, it will be parsed as a leaf command,
if the expression is a module definition or module name, it
will be parsed as a node command. This macro must be used with
[`@main`](@ref) to create a multi-command CLI.

# Quick Example

```julia
# in a script or module

\"\"\"
sum two numbers.

# Args

- `x`: first number
- `y`: second number

# Options

- `-p, --precision=<type>`: precision of the calculation.

# Flags

- `-f, --fastmath`: enable fastmath.

\"\"\"
@cast function sum(x, y; precision::String="float32", fastmath::Bool=false)
    # implementation
    return
end

"product two numbers"
@cast function prod(x, y)
    return
end

@main
```
"""
macro cast(ex)
    esc(codegen_ast_cast(__module__, QuoteNode(__source__), ex))
end


macro main(ex)
    esc(codegen_entry(__module__, QuoteNode(__source__), ex))
end

"""
    @main
    @main <function definition>

Main entry of the CLI application.

# Quick Example

```julia
# in a script or module

\"\"\"
sum two numbers.

# Args

- `x`: first number
- `y`: second number

# Options

- `-p, --precision=<type>`: precision of the calculation.

# Flags

- `-f, --fastmath`: enable fastmath.

\"\"\"
@main function sum(x, y; precision::String="float32", fastmath::Bool=false)
    # implementation
    return
end
```

$MAIN_DOCSTRING
"""
macro main()
    esc(codegen_entry(__module__, QuoteNode(__source__)))
end

function codegen_ast_cast(m::Module, line, ex)
    if ex isa Symbol
        casted = codegen_ast_cast_module(m, line, ex)
    elseif Meta.isexpr(ex, :module)
        casted = codegen_ast_cast_module(m, line, ex)
    elseif is_function(ex)
        casted = codegen_ast_cast_function(m, line, ex)
    else
        error("unkown expression: $ex, expect module name or function definition")
    end

    return quote
        $(codegen_casted_commands(m))
        $casted
    end
end

function is_argument_with_type(ex)
    ex isa Expr || return false
    return Meta.isexpr(ex, :(::))
end

function is_vararg_with_type(ex)
    ex isa Expr || return false
    Meta.isexpr(ex, :(...)) || return false
    return is_argument_with_type(ex.args[1])
end

function is_optional_argument_with_type(ex)
    ex isa Expr || return false
    Meta.isexpr(ex, :kw) || return false
    return is_argument_with_type(ex.args[1])
end

function split_leaf_command(fn::JLFunction)
    # use ::<type> as hint if there is no docstring
    args = map(fn.args) do each
        if each isa Symbol
            xcall(Comonicon, :JLArgument; name = QuoteNode(each))
        elseif is_argument_with_type(each) # :($name::$type)
            xcall(
                Comonicon,
                :JLArgument;
                name = QuoteNode(each.args[1]),
                type = wrap_type(fn, each.args[2]),
            )
        elseif is_vararg_with_type(each) # :($name::$type...)
            name = each.args[1].args[1]
            type = each.args[1].args[2]
            xcall(
                Comonicon,
                :JLArgument;
                name = QuoteNode(name),
                type = wrap_type(fn, type),
                require = false,
                vararg = true,
            )
        elseif is_optional_argument_with_type(each) # Expr(:kw, :($name::$type), value)
            name = each.args[1].args[1]
            type = each.args[1].args[2]
            value = each.args[2]
            xcall(
                Comonicon,
                :JLArgument;
                name = QuoteNode(name),
                type = wrap_type(fn, type),
                require = false,
                default = string(value),
            )
        elseif Meta.isexpr(each, :...) # :($name...)
            xcall(Comonicon, :JLArgument; name = QuoteNode(each.args[1]), require = false, vararg = true)
        elseif Meta.isexpr(each, :kw) && each.args[1] isa Symbol # Expr(:kw, name::Symbol, value)
            xcall(
                Comonicon,
                :JLArgument;
                name = QuoteNode(each.args[1]),
                require = false,
                default = string(each.args[2]),
            )
        else
            throw(Meta.ParseError("invalid syntax: $each"))
        end
    end

    flags, options = [], []
    if !isnothing(fn.kwargs)
        for each in fn.kwargs
            Meta.isexpr(each, :kw) ||
                error("options should have default values or make it a positional argument")
            expr = each.args[1]
            value = each.args[2]
            if expr isa Symbol # Expr(:kw, name::Symbol, value)
                push!(options, xcall(Comonicon, :JLOption, QuoteNode(expr), Any, string(value)))
            elseif Meta.isexpr(expr, :(::))
                name = expr.args[1]
                type = expr.args[2]

                if type === :Bool || type === Bool
                    value == false || error(
                        "Boolean options must use false as " *
                        "default value, and will be parsed as flags. got $name",
                    )
                    push!(flags, xcall(Comonicon, :JLFlag, QuoteNode(name)))
                else
                    push!(
                        options,
                        xcall(
                            Comonicon,
                            :JLOption,
                            QuoteNode(name),
                            type,
                            string(value) * "::" * string(type),
                        ),
                    )
                end
            end
        end
    end
    args = Expr(:ref, :($Comonicon.JLArgument), args...)
    options = Expr(:ref, :($Comonicon.JLOption), options...)
    flags = Expr(:ref, :($Comonicon.JLFlag), flags...)
    return args, options, flags
end

function wrap_type(def::JLFunction, type)
    def.whereparams === nothing && return type
    return Expr(:where, type, def.whereparams...)
end

function codegen_ast_cast_function(m::Module, @nospecialize(line), ex::Expr)
    fn = JLFunction(ex)
    args, options, flags = split_leaf_command(fn)

    @gensym cmd
    name = default_name(fn.name)
    return quote
        $ex
        Core.@__doc__ $(fn.name)
        $cmd = $Comonicon.cast($(fn.name), $name, $args, $options, $flags, $line)
        $Comonicon.set_cmd!($m.CASTED_COMMANDS, $cmd, $name)
    end
end

function codegen_ast_cast_module(m::Module, line, ex)
    name = name_only(ex)
    @gensym cmd
    cmd_name = default_name(name)
    return quote
        $(Expr(:toplevel, ex))
        Core.@__doc__ $name
        $cmd = $Comonicon.cast($name, $cmd_name, $line)
        $Comonicon.set_cmd!($m.CASTED_COMMANDS, $cmd, $cmd_name)
    end
end

function codegen_create_entry(m::Module, line, @nospecialize(ex))
    @gensym cmd entry
    configs = Configs.read_options(m)
    julia_expr_configs = JuliaExpr.Configs(;
        configs.command.width,
        configs.command.color,
        configs.command.static,
        configs.command.dash,
    )
    quote
        $(codegen_entry_cmd(m::Module, line, cmd, configs, ex))
        $entry = $Comonicon.AST.Entry($cmd, $(get_version(m)), $line)
        $Comonicon.set_cmd!($m.CASTED_COMMANDS, $entry, "main")
        $m.eval($JuliaExpr.emit($entry, $(julia_expr_configs)))
    end
end

function codegen_entry(m::Module, line, @nospecialize(ex = nothing))
    if m === Main
        codegen_script_entry(m, line, ex)
    else
        codegen_project_entry(m, line, ex)
    end
end

function codegen_script_entry(m::Module, line, @nospecialize(ex))
    quote
        $(codegen_create_entry(m, line, ex))
        command_main()
    end
end

function codegen_project_entry(m::Module, line, @nospecialize(ex))
    include_deps_ex = if Configs.has_comonicon_toml(m)
        :(include_dependency($(Configs.find_comonicon_toml(pkgdir(m)))))
    else
        nothing
    end

    quote
        $(codegen_create_entry(m, line, ex))

        # entry point for apps
        function julia_main()::Cint
            try
                return command_main()
            catch
                Base.invokelatest(Base.display_error, Base.catch_stack())
                return 1
            end
        end

        """
            comonicon_install(;kwargs...)

        Install the CLI manually. This will use the default configuration in `Comonicon.toml`,
        if it exists. For more detailed reference, please refer to
        [Comonicon documentation](https://docs.comonicon.org).
        """
        comonicon_install(; kwargs...) = $Comonicon.Builder.command_main($m; kwargs...)

        """
            comonicon_install_path(;[yes=false])

        Install the `PATH` and `FPATH` to your shell configuration file.
        You can use `comonicon_install_path(;yes=true)` to skip interactive prompt.
        For more detailed reference, please refer to
        [Comonicon documentation](https://docs.comonicon.org).
        """
        comonicon_install_path(; yes = false) = $Comonicon.Builder.install_env_path($m; yes)

        precompile(Tuple{typeof($m.command_main),Array{String,1}})

        $include_deps_ex # make sure we recompile the package when Comonicon.toml changes
    end
end

function codegen_entry_cmd(m::Module, line, cmd, configs, ex)
    if isnothing(ex)
        return codegen_multiple_main_entry(m, line, cmd, configs)
    else
        return codegen_single_main_entry(m, line, cmd, ex)
    end
end

function codegen_multiple_main_entry(m::Module, line, cmd, configs)
    name = configs.name

    @gensym doc
    return quote
        Core.@__doc__ const COMMAND_ENTRY_DOC_STUB = nothing
        $doc = @doc(COMMAND_ENTRY_DOC_STUB)
        if $Comonicon.has_docstring($doc)
            $doc = $Comonicon.read_description($doc)
        else
            $doc = nothing
        end

        $cmd = $Comonicon.AST.NodeCommand($name, copy($m.CASTED_COMMANDS), $doc, $line)
    end
end

function codegen_single_main_entry(m::Module, line, cmd, ex)
    fn = JLFunction(ex)
    args, options, flags = split_leaf_command(fn)
    name = default_name(fn.name)
    return quote
        $(codegen_casted_commands(m))
        $ex
        Core.@__doc__ $(fn.name)
        $cmd = $Comonicon.cast($(fn.name), $name, $args, $options, $flags, $line)
    end
end

function codegen_casted_commands(m::Module)
    isdefined(m, :CASTED_COMMANDS) && return
    return :(const CASTED_COMMANDS = Dict{String,Any}())
end

function cast(m::Module, name::String = default_name(m), line = LineNumberNode(0))
    isdefined(m, :CASTED_COMMANDS) || error("module $m does not contain any @cast commands")
    desc, intro = split_docstring(m)
    NodeCommand(name, copy(m.CASTED_COMMANDS), Description(desc, intro), line)
end

function cast(
    f::Function,
    name::String,
    args::Vector{JLArgument} = JLArgument[],
    options::Vector{JLOption} = JLOption[],
    flags::Vector{JLFlag} = JLFlag[],
    line = LineNumberNode(0),
)
    doc = split_docstring(f)::JLMD
    args, vararg = cast_args(doc, args, line)
    flags = cast_flags(doc, flags, line)
    options = cast_options(doc, options, line)
    return LeafCommand(
        f,
        name,
        args,
        count(x -> x.require, args),
        vararg,
        flags,
        options,
        Description(doc.desc, doc.intro),
        line,
    )
end

function cast_args(doc::JLMD, args::Vector{JLArgument}, line)

    # if no arguments
    if length(args) == 0
        return Argument[], nothing
    end

    args = map(args) do each
        Argument(
            string(each.name),
            each.type,
            each.vararg,
            each.require,
            each.default,
            Description(get(doc.arguments, string(each.name), nothing)),
            line,
        )
    end

    if last(args).vararg
        return args[1:end-1], last(args)
    else
        return args, nothing
    end
end

function cast_flags(doc::JLMD, flags::Vector{JLFlag}, line)
    cmd_flags = Dict{String,Flag}()
    for each in flags
        name = replace(string(each.name), '_' => '-')
        if haskey(doc.flags, name)
            doc_flag = doc.flags[name]::JLMDFlag
            cmd_flags[name] =
                flg = Flag(;
                    sym = each.name,
                    name = name,
                    short = doc_flag.short,
                    description = Description(doc_flag.desc),
                    line = line,
                )

            if doc_flag.short
                cmd_flags[name[1:1]] = flg
            end
        else
            cmd_flags[name] = Flag(; sym = each.name, name = name, line = line)
        end
    end
    return cmd_flags
end

function cast_options(doc::JLMD, options::Vector{JLOption}, line)
    cmd_options = Dict{String,Option}()
    for each in options
        name = replace(string(each.name), '_' => '-')
        if haskey(doc.options, name)
            option = doc.options[name]::JLMDOption
            cmd_options[name] =
                opt = Option(;
                    sym = each.name,
                    name = name,
                    hint = option.hint, # use user defined hint
                    type = each.type,
                    short = option.short,
                    description = option.desc,
                    line = line,
                )

            if option.short
                cmd_options[name[1:1]] = opt
            end
        else
            cmd_options[name] = Option(;
                sym = each.name,
                name = name,
                hint = each.hint,
                type = each.type,
                line = line,
            )
        end
    end
    return cmd_options
end
