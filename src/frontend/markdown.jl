const PARSED_SECTION = [
    "Intro",
    "Introduction", # long description
    "Arguments",
    "Args", # arguments
    "Options",
    "Flags", # kwargs
]

function split_docstring(f::Function)
    doc = Base.Docs.doc(f)
    return split_docstring(doc)
end

function split_docstring(m::Module)
    doc = Base.Docs.doc(m)
    has_docstring(doc) || return "", ""
    return read_description(doc), read_intro(doc)
end

function split_docstring(doc::Markdown.MD)
    has_docstring(doc) || return JLMD()
    desc = read_description(doc)
    intro = read_intro(doc)
    args = read_arguments(doc)
    flags = read_flags(doc)
    options = read_options(doc)
    return JLMD(desc, intro, args, options, flags)
end

function has_docstring(doc::Markdown.MD)
    content = read_content(doc)
    isempty(content) && return false
    paragraph = first(content)
    flag = paragraph isa Markdown.Paragraph && paragraph.content == Any["No documentation found."]
    return !flag
end

function read_intro(md::Markdown.MD)
    sec = read_section(md, ["Intro", "Introduction"])
    isempty(sec) && return ""
    length(sec) == 1 || error("section Intro/Introduction can only have one paragraph")
    return strip(md_to_string(Markdown.MD(sec, md.meta)))
end

function read_arguments(md::Markdown.MD)
    args = Dict{String,String}()
    sec = read_section(md, ["Arguments", "Args"])
    isempty(sec) && return args
    length(sec) == 1 || error("section Arguments/Args can only have one paragraph")
    sec = sec[]

    for each in sec.items
        name, doc = read_item(each[1])
        args[name] = doc
    end
    return args
end

function read_flags(md::Markdown.MD)
    flags = Dict{String,JLMDFlag}()
    sec = read_section(md, "Flags")
    isempty(sec) && return flags
    length(sec) == 1 || error("section Flags can only have one paragraph")
    sec = sec[]

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
    isempty(sec) && return options
    length(sec) == 1 || error("section Options can only have one paragraph")
    sec = sec[]

    for each in sec.items
        code, doc = read_item(each[1])
        name, short, hint = split_option(code)
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
        if line isa Markdown.Header{1} && line.text[1] in PARSED_SECTION
            break
        else
            push!(intro, line)
        end
    end
    isempty(intro) && return ""
    return strip(md_to_string(Markdown.MD(intro, md.meta)))
end

function read_section(md::Markdown.MD, title::Vector{String})
    for each in title
        sec = read_section(md, each)
        isempty(sec) || return sec
    end
    return []
end

function read_section(md::Markdown.MD, title::String)::Vector{Any}
    ct = read_content(md)
    nlines = length(ct)
    content = []
    for k in 1:nlines
        line = ct[k]
        if line isa Markdown.Header{1} && line.text[1] == title
            k + 1 ≤ nlines || return content # return on last line
            for idx in k+1:nlines
                ct[idx] isa Markdown.Header{1} && return content # another title
                push!(content, ct[idx])
            end
        end
    end
    return content
end

read_content(x) = x
function read_content(md::Markdown.MD)
    if !isempty(md.content) && md.content[1] isa Markdown.MD
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

function md_to_string(md::Markdown.MD) # don't print newlines for one paragraph
    return _sprint(md; color = true, displaysize = (typemax(Int), 1000)) do io, x
        show(io, MIME"text/plain"(), x)
    end
end

function split_option(content::String)
    content = strip(content)
    startswith(content, "-") || throw(Meta.ParseError("expect --option[,-o], got $content"))
    names = map(strip, split(content, ",")) # rm space

    if length(names) == 1 # long option
        long, hint = split_hint(lstrip(names[1], '-'))
        short = nothing
    elseif length(names) == 2 # short option
        if startswith(names[1], "--") && !startswith(names[2], "--") && startswith(names[2], '-') # --option, -o
            long, (short, hint) = lstrip(names[1], '-'), split_hint(lstrip(names[2], '-'))
        elseif startswith(names[2], "--") && !startswith(names[1], "--") && startswith(names[1], '-') # -o, --option
            (long, hint), short = split_hint(lstrip(names[2], '-')), lstrip(names[1], '-')
        else
            error("expect --option[, -o], got $content")
        end

        length(short) == 1 ||
            throw(Meta.ParseError("short option can only use one letter, got $content"))
        first(short) == first(long) ||
            throw(Meta.ParseError("short option must use the same first letter, got $content"))
    else
        throw(Meta.ParseError("too much inputs, expect --option[,-o], got $content"))
    end
    long = replace(long, '_' => '-')
    return long, short, hint
end

function split_hint(content::AbstractString)
    msg = "expect --option[,-o]=<hint> or --option[,-o] <hint>, got $content"
    content = strip(content)
    m = match(r"([^\s]+)(?:\s+|=)(<.+>)", content)

    # no hint, just -o, --option
    # shouldn't contain inner space
    if m === nothing
        any(x -> isspace(x) || isequal(x, '='), content) && throw(Meta.ParseError(msg))
        return content, nothing
    end

    return m[1], strip(m[2], ['<', '>'])
end
