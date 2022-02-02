"""
    CommandException <: Exception

Abstract type for command exceptions. All command exceptions
except `CommandTerminate` should contain an `exitcode` field.
"""
abstract type CommandException <: Exception end

struct CommandTerminate <: CommandException end
struct CommandError <: CommandException
    msg::String
    exitcode::Int
end

CommandError(msg::String) = CommandError(msg, 1)

function Base.showerror(io::IO, e::CommandError)
    print(io, "CommandError: ", e.msg, " exit with ", e.exitcode)
end
