# module DumpTruck

if VERSION >= v"1.13"
using Base: takestring!
else
takestring! = String ∘ take!
end

function highlight
end

if isdefined(REPL, :JuliaSyntaxHighlighting) # VERSION >= v"1.12"
    function highlight(io, x::AbstractString)
        REPL.JuliaSyntaxHighlighting.highlight(x)
    end
    function highlight(io, x)
        s = sprint(show, "text/plain", x)
        REPL.JuliaSyntaxHighlighting.highlight(s)
    end
else
    const have_color::Bool = Base.JLOptions().color == 2 ? false : true

    function sprint_colored(io, @nospecialize(x); color::Symbol)
        if get(io, :color, have_color)
            buf = IOBuffer()
            io_buf = IOContext(buf, :color => true)
            printstyled(io_buf, x; color = color)
            takestring!(buf)
        else
            sprint(print, x)
        end
    end

    function highlight(io, x::DataType)
        sprint_colored(io, x; color = :yellow)
    end
    function highlight(io, x::Union)
        sprint_colored(io, x; color = :yellow)
    end
    function highlight(io, x::Type{<: Number})
        sprint_colored(io, x; color = :light_yellow)
    end
    function highlight(io, x::Ptr)
        sprint_colored(io, repr(x); color = :light_magenta)
    end
    function highlight(io, x::Number)
        sprint_colored(io, x; color = :light_magenta)
    end
    function highlight(io, x::AbstractString)
        sprint_colored(io, x; color = :light_green)
    end
    function highlight(io, x::Symbol)
        sprint_colored(io, repr(x); color = :light_green)
    end
    function highlight(io, x::Nothing)
        sprint_colored(io, x; color = :magenta)
    end
    function highlight(io, x)
        sprint(show, "text/plain", x)
    end
end

# module DumpTruck
