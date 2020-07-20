const PRESERVED = ["h", "help"]

function check_duplicate_short_options(options, flags)
    flags_and_options = Iterators.flatten((options, flags))

    for cmd in flags_and_options
        if cmd_name(cmd) in PRESERVED
            error("$cmd is preserved")
        end

        n_duplicate = count(flags_and_options) do x
            cmd_name(x) == cmd_name(cmd)
        end

        if n_duplicate > 1
            error("$cmd is duplicated, found $n_duplicate")
        end

        if cmd.short
            first_letter = string(first(cmd_name(cmd)))
            if first_letter in PRESERVED
                error("$cmd cannot use short version since -$first_letter is preserved.")
            end

            n_duplicate = count(flags_and_options) do x
                x.short && string(first(cmd_name(x))) == first_letter
            end

            if n_duplicate > 1
                error("the short version of $cmd is duplicated, $n_duplicate found")
            end
        end
    end
    return
end

function check_required_args(args)
    count = 0
    prev_require = 0
    for (i, arg) in enumerate(args)
        if arg.require
            prev_require + 1 == i || error("optional positional arguments must occur at end")
            count += 1
            prev_require = i
        end
    end
    return count
end
