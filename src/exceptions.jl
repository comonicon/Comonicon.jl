"""
    CommandException <: Exception

Abstract type for command exceptions. All command exceptions
should contain an `exitcode` field.
"""
abstract type CommandException <: Exception end

"""
    struct CommandExit <: CommandException

Exception type for [`cmd_exit`](@ref).
"""
struct CommandExit <: CommandException
    exitcode::Int
end

"""
    struct CommandError <: CommandException

Exception type for general CLI compatible errors thrown
by [`cmd_error`](@ref).
"""
struct CommandError <: CommandException
    msg::String
    exitcode::Int
end

"""
    cmd_error(msg::String, code::Int = 1)

Throw a `CommandError` with message `msg` and return
code `code`. This is preferred as exception handle
when writing a CLI compatible Julia program.

When the program is running in normal Julia execution
the error will print as normal Julia exception with
stacktrace.

When the progrm is running from a CLI entry, the exception
is printed as standard CLI exceptions with exit code (default
is `1`). Then the corresponding help message is printed.
"""
cmd_error(msg::String, code::Int = 1) = throw(CommandError(msg, code))

"""
    cmd_exit(code::Int = 0)

Exit the CLI program with `code`. This method is preferred
over `exit` to make sure the program won't exit directly
without handling the exception.
"""
cmd_exit(code::Int = 0) = throw(CommandExit(code))

function Base.showerror(io::IO, e::CommandError)
    print(io, "CommandError: ", e.msg, " exit with ", e.exitcode)
end
