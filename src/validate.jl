const PRESERVED = ["h", "help", "version", "V"]

function check_duplicate_short_options(options, flags)
    for option in options
        if cmd_name(option) in PRESERVED
            error("$option is preserved")
        end

        if option.short
            first_letter = string(first(cmd_name(option)))
            if first_letter in PRESERVED
                error("$option cannot be a short option since -$first_letter is preserved.")
            end
        end
    end

    for flag in flags
        if cmd_name(flag) in PRESERVED
            error("$flag is preserved")
        end

        if flag.short
            first_letter = string(first(cmd_name(flag)))
            if first_letter in PRESERVED
                error("$flag cannot be a short flag since -$first_letter is preserved.")
            end
        end
    end
    return
end
