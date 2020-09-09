# NOTE: all command entries are restricted to have only one method
# thus we always have at most one doc string.

function read_content(md::Markdown.MD)
    if md.content[1] isa Markdown.MD
        return read_content(md.content[1])
    else
        return md.content
    end
end

read_content(x) = x

"""
    rm_format(md)

Remove Markdown DOM and flatten to strings.
"""
function rm_format end
rm_format(x::Markdown.Paragraph) = join(map(rm_format, x.content))
rm_format(x::Markdown.Code) = x.code
rm_format(x::String) = x
rm_format(x::Markdown.MD) = rm_format(x.content[1])

"""
    read_doc(markdown)

Read CLI documentation from markdown format doc strings.
"""
function read_doc(doc::Markdown.MD)
    has_docstring(doc) || return "", read_args(nothing), read_flags(nothing), read_options(nothing)
    intro = read_intro(doc)
    
    long_sec = read_section(doc, "Arguments")
    short_sec = read_section(doc, "Args")

    if long_sec !== nothing && short_sec !== nothing
        error("expecting a single section about arguments, got Args and Arguments")
    end

    if long_sec === nothing
        args = read_args(short_sec)
    else
        args = read_args(long_sec)
    end

    flags = read_flags(read_section(doc, "Flags"))
    options = read_options(read_section(doc, "Options"))
    return intro, args, flags, options
end

function read_intro(md::Markdown.MD)
    intro = []
    for line in read_content(md)
        if line isa Markdown.Header{1} && line.text[1] in ["Arguments", "Args", "Options", "Flags"]
            break
        else
            push!(intro, line)
        end
    end
    return join(map(rm_format, intro), "\n")
end

function read_section(md::Markdown.MD, title)
    ct = read_content(md)
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

read_args(::Nothing) = Dict{String,String}()
read_flags(::Nothing) = Dict{String,Tuple{String,Bool}}()
read_options(::Nothing) = Dict{String,Tuple{String,String,Bool}}()

function read_args(md::Markdown.List)
    args = Dict{String,String}()
    for each in md.items
        name, doc = read_item(each[1])
        args[name] = doc
    end
    return args
end

function read_options(md::Markdown.List)
    options = Dict{String,Tuple{String,String,Bool}}()
    # (name, doc, short)
    for each in md.items
        name, doc = read_item(each[1])
        m = match(r"^(-.*) +<(.+)>$", name)

        if m === nothing
            err_m = match(r"^-.*$", strip(name))
            if err_m === nothing
                throw(Meta.ParseError("invalid option: $name"))
            else
                throw(Meta.ParseError("invalid option: $name, expect option argument doc, got only flag"))
            end
        end

        flags = split(m[1], ",")
        if length(flags) == 1
            startswith(name, "--") || throw(Meta.ParseError("invalid option/flag: $name"))
            options[lstrip(m[1], '-')] = (m[2], doc, false)
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

function read_flags(md::Markdown.List)
    options = Dict{String,Tuple{String,Bool}}()
    # (doc, short)
    for each in md.items
        name, doc = read_item(each[1])
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

function read_item(raw::Markdown.Paragraph)
    length(raw.content) == 2 || throw(Meta.ParseError("invalid command entry argument doc syntax"))
    raw.content[1] isa Markdown.Code ||
        throw(Meta.ParseError("command argument name should be marked by inline code"))
    name = raw.content[1].code
    doc = read_docstring(raw.content[2])
    return name, doc
end

function read_docstring(doc::String)
    m = match(r"^: *(.*)", strip(doc))
    m === nothing && throw(Meta.ParseError("invalid docstring format: $doc"))
    return String(m[1])
end

function has_docstring(doc::Markdown.MD)
    paragraph = first(read_content(doc))
    flag = paragraph isa Markdown.Paragraph && paragraph.content == Any["No documentation found."]
    return !flag
end
