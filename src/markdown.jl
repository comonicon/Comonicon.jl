function content(md)
    (md isa Markdown.MD) &&
    (md.content[1] isa Markdown.MD) &&
    (md.content[1].content[1] isa Markdown.MD) &&
    return md.content[1].content[1].content

    return []
end

rm_format(x::Markdown.Paragraph) = join(map(rm_format, x.content))
rm_format(x::Markdown.Code) = x.code
rm_format(x::String) = x

function parse_doc(md::Markdown.MD)
    intro = parse_intro(md)
    args = parse_args(find_section(md, "Arguments"))
    options = parse_options(find_section(md, "Options"))
    flags = parse_flags(find_section(md, "Flags"))

    return intro, args, options, flags
end

function create_maybe(f, list)
    if isempty(list)
        return Dict()
    else
        return f(list[1])
    end
end

function find_section(md::Markdown.MD, title)
    ct = content(md)
    nlines = length(ct)
    for k in 1:nlines
        line = ct[k]
        if line isa Markdown.Header{1} && line.text[1] == title
            if k + 1 <= nlines
                return ct[k+1]
            end
        end
    end
    return
end

function parse_intro(md::Markdown.MD)
    intro = []
    for line in content(md)
        if line isa Markdown.Header{1} && line.text[1] in ["Arguments", "Options", "Flags"]
            break
        else
            push!(intro, line)
        end
    end
    return join(map(rm_format, intro), "\n")
end

parse_flags(::Nothing) = Dict{String, Tuple{String, Bool}}()
parse_options(::Nothing) = Dict{String, Tuple{String, String, Bool}}()

function parse_flags(raw::Markdown.List)
    options = Dict{String, Tuple{String, Bool}}()
    # (name, doc, short)
    for each in raw.items
        name, doc = parse_item(each[1])
        flags = split(name, ",")
        if length(flags) == 1
            startswith(name, "--") || throw(Meta.ParseError("invalid flag: $name, might be --$name"))
            options[name[3:end]] = (doc, false)
        elseif length(flags) == 2
            names = strip.(flags)
            name = startswith(names[1], "--") ? lstrip(names[1], '-') :
                startswith(names[2], "--") ? lstrip(names[2], '-') :
                throw(Meta.ParseError("invalid flag: $name"))
            
            options[name] = (doc, true)
        else
            throw(Meta.ParseError("invalid flag syntax: $name"))
        end
    end
    return options
end

function parse_options(raw::Markdown.List)
    options = Dict{String, Tuple{String, String, Bool}}()
    # (name, doc, short)
    for each in raw.items
        name, doc = parse_item(each[1])
        m = match(r"^(-.*) +<(.+)>$", name)
        m === nothing && throw(Meta.ParseError("invalid option: $name"))

        flags = split(m[1], ",")
        if length(flags) == 1
            startswith(name, "--") || throw(Meta.ParseError("invalid option/flag: $name"))
            options[lstrip(name, "-")] = (m[2], doc, false)
        elseif length(flags) == 2
            names = strip.(flags)
            name = startswith(names[1], "--") ? lstrip(names[1], '-') :
                startswith(names[2], "--") ? lstrip(names[2], '-') :
                throw(Meta.ParseError("invalid option/flag: $name"))

            options[name] = (m[2], doc, true)
        else
            throw(Meta.ParseError("invalid option/flag syntax: $name"))
        end
    end
    return options
end

parse_args(::Nothing) = Dict{String, String}()

function parse_args(raw::Markdown.List)
    args = Dict{String, String}()
    for each in raw.items
        name, doc = parse_item(each[1])
        args[name] = doc
    end
    return args
end

function parse_item(raw::Markdown.Paragraph)
    length(raw.content) == 2 || throw(Meta.ParseError("invalid command entry argument doc syntax"))
    raw.content[1] isa Markdown.Code || throw(Meta.ParseError("command argument name should be marked by inline code"))
    name = raw.content[1].code
    doc = parse_docstring(raw.content[2])
    return name, doc
end

function parse_docstring(doc::String)
    m = match(r"^: *(.*)", doc)
    m === nothing && throw(Meta.ParseError("invalid docstring format: $doc"))
    return String(m[1])
end
