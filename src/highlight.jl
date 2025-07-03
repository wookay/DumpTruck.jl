# module DumpTruck

function highlight
end

if isdefined(REPL, :JuliaSyntaxHighlighting) # VERSION >= v"1.12"
    function highlight(s::AbstractString)
        REPL.JuliaSyntaxHighlighting.highlight(s)
    end
    function highlight(x)
        s = sprint(show, "text/plain", x)
        highlight(s)
    end
else
    function highlight(s::AbstractString)
        s
    end
    function highlight(x)
        s = sprint(show, "text/plain", x)
        highlight(s)
    end
end

# module DumpTruck
