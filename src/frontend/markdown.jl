function split_docstring(f::Function)
    doc = Base.Docs.doc(f)
    return split_docstring(doc)
end

function split_docstring(m::Module)
    doc = Base.Docs.doc(m)
    has_docstring(doc) || return
    return read_description(doc)
end

function split_docstring(doc::Markdown.MD)
    has_docstring(doc) || return JLMD()
    desc = read_description(doc)
    args = read_arguments(doc)
    flags = read_flags(doc)
    options = read_options(doc)
    return JLMD(desc, args, options, flags)
end

function has_docstring(doc::Markdown.MD)
    paragraph = first(read_content(doc))
    flag = paragraph isa Markdown.Paragraph && paragraph.content == Any["No documentation found."]
    return !flag
end

function read_arguments(md::Markdown.MD)
    args = Dict{String,String}()
    sec = read_section(md, ["Arguments", "Args"])
    sec === nothing && return args

    for each in sec.items
        name, doc = read_item(each[1])
        args[name] = doc
    end
    return args
end

function read_flags(md::Markdown.MD)
    flags = Dict{String,JLMDFlag}()
    sec = read_section(md, "Flags")
    sec === nothing && return flags

    for each in sec.items
        name, doc = read_item(each[1])
        name, short, hint = split_option(name)
        hint === nothing || error("flag cannot have hint")
        flags[name] = JLMDFlag(doc, short !== nothing)
    end
    return flags
end

function read_options(md::Markdown.MD)
    options = Dict{String,JLMDOption}()
    sec = read_section(md, "Options")
    sec === nothing && return options

    for each in sec.items
        name, doc = read_item(each[1])
        name, short, hint = split_option(name)
        options[name] = JLMDOption(hint, doc, !isnothing(short))
    end
    return options
end

function read_description(md::Markdown.MD)
    intro = []
    lines = read_content(md)
    # ignore julia function signature
    if lines[1] isa Markdown.Code
        lines = lines[2:end]
    end

    for line in lines
        if line isa Markdown.Header{1} && line.text[1] in ["Arguments", "Args", "Options", "Flags"]
            break
        else
            push!(intro, line)
        end
    end
    return strip(md_to_string(Markdown.MD(intro, md.meta)))
end

function read_section(md::Markdown.MD, title::Vector{String})
    for each in title
        sec = read_section(md, each)
        sec === nothing || return sec
    end
    return
end

function read_section(md::Markdown.MD, title::String)
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

read_content(x) = x
function read_content(md::Markdown.MD)
    if md.content[1] isa Markdown.MD
        return read_content(md.content[1])
    else
        return md.content
    end
end

function read_item(raw::Markdown.Paragraph)
    raw.content[1] isa Markdown.Code ||
        throw(Meta.ParseError("command argument name should be marked by inline code"))
    name = raw.content[1].code

    raw_doc = md_to_string(Markdown.MD(Markdown.Paragraph(raw.content[2:end])))
    doc = read_docstring(raw_doc)
    return name, doc
end

function read_docstring(doc::String)
    m = match(r"^: *(.*)", strip(doc))
    m === nothing && throw(Meta.ParseError("invalid docstring format: $doc"))
    return String(m[1])
end

"""
    rm_format(md)

Remove Markdown DOM and flatten to strings.
"""
function rm_format end
rm_format(x::Markdown.Paragraph) = join(map(rm_format, x.content))
rm_format(x::Markdown.Code) = x.code
rm_format(x::String) = x
rm_format(x::Markdown.MD) = rm_format(x.content[1])

function docstring(x)
    return sprint(Base.Docs.doc(x); context = :color => true) do io, x
        show(io, MIME"text/plain"(), x)
    end
end

function md_to_string(md::Markdown.MD)
    return sprint(md; context = :color => true) do io, x
        show(io, MIME("text/plain"), x)
    end
end

function split_option(content::String)
    content = strip(content)
    startswith(content, "--") || throw(Meta.ParseError("expect --option[,-o], got $content"))
    content = lstrip(content, '-')
    names = split(content, ",")
    if length(names) == 1 # long option
        name, hint = split_hint(names[1])
        short = nothing
    elseif length(names) == 2 # short option
        name = names[1]
        short = lstrip(names[2])
        startswith(short, "-") || throw(Meta.ParseError("expect --option,-o, got --$content"))
        short, hint = split_hint(lstrip(short, '-'))
        length(short) == 1 || throw(Meta.ParseError("short option can only use one letter, got --$content"))
        first(short) == first(name) || throw(Meta.ParseError("short option must use the same first letter, got --$content"))
    else
        throw(Meta.ParseError("too much inputs, expect --option[,-o], got --$content"))
    end
    name = replace(name, '_'=>'-')
    return name, short, hint
end

function split_hint(content::AbstractString)
    content = strip(content)
    if occursin('=', content)
        splited = split(content, '=')
    else
        splited = split(content)
    end
    length(splited) == 1 && return splited[1], nothing

    length(splited) == 2 && startswith(splited[2], '<') && endswith(splited[2], '>') ||
        throw(Meta.ParseError("expect --option[,-o]=<hint> or --option[,-o] <hint>"))
    return splited[1], strip(splited[2], ['<', '>'])
end
