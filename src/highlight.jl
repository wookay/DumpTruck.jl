# module DumpTruck

if VERSION >= v"1.13"
using Base: takestring!
else
takestring! = String ∘ take!
end

function highlight
end

if isdefined(REPL, :JuliaSyntaxHighlighting) # VERSION >= v"1.12"
    function highlight(x::AbstractString)
        REPL.JuliaSyntaxHighlighting.highlight(x)
    end
    function highlight(x)
        s = sprint(show, "text/plain", x)
        REPL.JuliaSyntaxHighlighting.highlight(s)
    end
else
    const have_color::Bool = Base.JLOptions().color == 2 ? false : true

    function sprint_colored(@nospecialize(x); color::Symbol)
        io = IOBuffer()
        printstyled(IOContext(io, :color => have_color), x; color = color)
        takestring!(io)
    end

    function highlight(x::DataType)
        sprint_colored(x; color = :yellow)
    end
    function highlight(x::Union)
        sprint_colored(x; color = :yellow)
    end
    function highlight(x::Type{<: Number})
        sprint_colored(x; color = :light_yellow)
    end
    function highlight(x::Ptr)
        sprint_colored(repr(x); color = :light_magenta)
    end
    function highlight(x::Number)
        sprint_colored(x; color = :light_magenta)
    end
    function highlight(x::AbstractString)
        sprint_colored(x; color = :light_green)
    end
    function highlight(x::Symbol)
        sprint_colored(repr(x); color = :light_green)
    end
    function highlight(x::Nothing)
        sprint_colored(x; color = :magenta)
    end
    function highlight(x)
        s = sprint(show, "text/plain", x)
        s
    end
end

# module DumpTruck
