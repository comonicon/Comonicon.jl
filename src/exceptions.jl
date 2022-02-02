"""
    CommandException <: Exception

Abstract type for command exceptions. All command exceptions
should contain an `exitcode` field.
"""
abstract type CommandException <: Exception end

struct CommandExit <: CommandException
    exitcode::Int
end

struct CommandError <: CommandException
    msg::String
    exitcode::Int
end

cmd_error(msg::String, code::Int=1) = throw(CommandError(msg, code))
cmd_exit(code::Int=0) = throw(CommandExit(code))

function Base.showerror(io::IO, e::CommandError)
    print(io, "CommandError: ", e.msg, " exit with ", e.exitcode)
end
