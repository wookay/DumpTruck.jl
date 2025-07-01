# module DumpTruck

using REPL

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

# from julia/base/show.jl
function dump_x(io::IOContext, @nospecialize(x), n::Int, indent)
    print(io, highlight(typeof(x)))
    print(io, "  ")
    print(io, highlight(repr(x)))
end

using Base: show_circular, dump_elts
function dump_x(io::IOContext, x::Array, n::Int, indent)
    print(io, highlight(string("Array{", eltype(x), "}")))
    print(io, "  size = ", highlight(size(x)))
    if eltype(x) <: Number
        print(io, "  ")
        print(io, highlight(repr(x)))
    else
        if n > 0 && !isempty(x) && !show_circular(io, x)
            println(io)
            recur_io = IOContext(io, :SHOWN_SET => x)
            lx = length(x)
            if get(io, :limit, false)::Bool
                dump_elts(recur_io, x, n, indent, 1, (lx <= 10 ? lx : 5))
                if lx > 10
                    println(io)
                    println(io, indent, "  ...")
                    dump_elts(recur_io, x, n, indent, lx - 4, lx)
                end
            else
                dump_elts(recur_io, x, n, indent, 1, lx)
            end
        end
    end
    nothing
end

using Base: undef_ref_str
function dump_object(io::IOContext, @nospecialize(x), n::Int, indent)
    if x === Union{}
        show(io, x)
        return
    end
    T = typeof(x)
    if isa(x, Function)
        print(io, x, " (function of type ", highlight(T), ")")
    else
        print(io, highlight(T))
    end
    nf = nfields(x)
    if nf > 0
        if n > 0 && !show_circular(io, x)
            recur_io = IOContext(io, Pair{Symbol,Any}(:SHOWN_SET, x))
            for field in 1:nf
                println(io)
                fname = string(fieldname(T, field))
                print(io, indent, "  ", fname, ": ")
                if isdefined(x,field)
                    dump_x(recur_io, getfield(x, field), n - 1, string(indent, "  "))
                else
                    print(io, undef_ref_str)
                end
            end
        end
    elseif !isa(x, Function)
        print(io, " ")
        show(io, x)
    end
    nothing
end

import Base: dump
# overrided by indent::String
function dump(io::IOContext, x::Expr, n::Int, indent::String)
    dump_object(io, x, n, indent)
end

function dump(io::IOContext, x::Symbol, n::Int, indent::String)
    dump_object(io, x, n, indent)
end

function dump(io::IOContext, x::String, n::Int, indent::String)
    dump_object(io, x, n, indent) # @nospecialize(x)
end

function dump(io::IOContext, x::AbstractString, n::Int, indent::String)
    dump_object(io, x, n, indent) # @nospecialize(x)
end

function dump(io::IOContext, x::Array, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, @nospecialize(x), n::Int, indent::String)
    dump_object(io, x, n, indent)
end

# module DumpTruck
