"""
    splittext(s)

Split the text in string `s` into an array, but keep all the separators
attached to the preceding word.

!!! note

    this is copied from Luxor/text.jl
"""
function splittext(s::String)
    # split text into array, keeping all separators
    # hyphens stay with first word
    result = Array{String,1}()
    iobuffer = IOBuffer()
    for c in s
        if isspace(c)
            push!(result, String(take!(iobuffer)))
            iobuffer = IOBuffer()
        elseif c == '-' # hyphen splits words but needs keeping
            print(iobuffer, c)
            push!(result, String(take!(iobuffer)))
            iobuffer = IOBuffer()
        else
            print(iobuffer, c)
        end
    end
    push!(result, String(take!(iobuffer)))
    return result
end

"""
    splitlines(s, width = 80)

Split a given string into lines of width `80` characters.
"""
function splitlines(s, width = 80)
    words = splittext(s)
    lines = String[]
    current_line = String[]
    space_left = width
    for word in words
        word == "" && continue
        word_width = length(word)

        if space_left < word_width
            # start a new line
            push!(lines, strip(join(current_line)))
            current_line = String[]
            space_left = width
        end

        if endswith(word, "-")
            push!(current_line, word)
            space_left -= word_width
        else
            push!(current_line, word * " ")
            space_left -= word_width + 1
        end
    end
    isempty(current_line) || push!(lines, strip(join(current_line)))
    return lines
end

function content_brief(s; max_width = 80)
    words = splittext(s)
    brief = String[]
    char_count = 0
    for word in words
        char_count += length(word) + 1
        # length should be max_width-3
        # but we overcount a space for
        # the last word.
        char_count > max_width-2 && break
        push!(brief, word)
    end
    return join(brief, ' ') * "..."
end
