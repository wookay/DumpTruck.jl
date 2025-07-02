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

function in_julia_core(m::Module)
    m in (Core, Base)
end

function dump_x(io::IOContext, @nospecialize(x), n::Int, indent)
    print(io, highlight(typeof(x)))
    print(io, "  ")
    print(io, highlight(repr(x)))
end

function dump_x(io::IOContext, x::AbstractChar, n::Int, indent)
    print(io, highlight(typeof(x)))
    print(io, "  ")
    if isdefined(REPL, :show_repl)
        REPL.show_repl(io, MIME("text/plain"), x)
    else
        show(io, "text/plain", x)
    end
end

function dump_x(io::IOContext, x::Bool, n::Int, indent)
    print(io, highlight(typeof(x)))
    print(io, "  ")
    printstyled(io, x; color = x ? :light_green : :light_red)
end

function dump_x(io::IOContext, x::Module, n::Int, indent)
    print(io, highlight(typeof(x)))
    print(io, "  ")
    if in_julia_core(x)
        printstyled(io, x; color = :light_blue)
    else
        printstyled(io, x; color = :green)
    end
end

# from julia/base/show.jl  function dump_elts(io::IOContext, x::Array, n::Int, indent, i0, i1)
using Base: undef_ref_str
function dump_elts_x(io::IOContext, x::Array, n::Int, indent, i0, i1)
    for i in i0:i1
        print(io, indent, "  ")
        printstyled(io, i; color = :light_cyan)
        print(io, ": ")
        if !isassigned(x,i)
            print(io, highlight(undef_ref_str))
        else
            dump(io, x[i], n - 1, string(indent, "  "))
        end
        i < i1 && println(io)
    end
end

function dump_elts_delim_array(io::IOContext, x, n::Int, indent, i0, i1)
    for i in i0:i1
        if !isassigned(x, i)
            print(io, highlight(undef_ref_str))
        else
            print(io, highlight(repr(x[i])))
        end
        i < i1 && print(io, ", ")
    end
end

function dump_elts_delim_dict(io::IOContext, dict, dict_keys, n::Int, indent, i0, i1)
    for i in i0:i1
        k = dict_keys[i]
        v = dict[k]
        print(io, highlight(repr(k => v)))
        i < i1 && print(io, ", ")
    end
end

# from julia/base/show.jl  function dump(io::IOContext, x::Array, n::Int, indent)
function dump_x(io::IOContext, x::AbstractDict{K,V}, n::Int, indent) where {K,V}
    print(io, highlight(typeof(x)))
    print(io, "  length = ", highlight(length(x)))
    if n > 0 && !isempty(x)
        println(io)
        recur_io = IOContext(io, :SHOWN_SET => x)
        dict_keys = collect(keys(x))
        lx = length(x)
        if get(io, :limit, false)::Bool
            print(io, indent, "  ")
            dump_elts_delim_dict(recur_io, x, dict_keys, n, indent, 1, (lx <= 10 ? lx : 5))
            if lx > 10
                print(io, ",")
                println(io)
                print(io, indent, "  ")
                printstyled(io, "… "; color = :light_black)
                println(io)
                print(io, indent, "  ")
                dump_elts_delim_dict(recur_io, x, dict_keys, n, indent, lx - 4, lx)
            end
        else
            dump_elts_delim_dict(recur_io, x, dict_keys, n, indent, 1, lx)
        end
    end
end

# from julia/base/show.jl  function dump(io::IOContext, x::Array, n::Int, indent)
using Base: show_circular, dump_elts
function dump_x(io::IOContext, x::Union{Memory, Array}, n::Int, indent)
    print(io, highlight(repr(typeof(x))))
    print(io, "  size = ", highlight(size(x)))
    if x isa Memory || eltype(x) <: Number
        if n > 0 && !isempty(x) && !show_circular(io, x)
            print(io, "  ")
            printstyled("["; color = :light_yellow)
            recur_io = IOContext(io, :SHOWN_SET => x)
            lx = length(x)
            if get(io, :limit, false)::Bool
                dump_elts_delim_array(recur_io, x, n, indent, 1, (lx <= 10 ? lx : 5))
                if lx > 10
                    print(io, ", ")
                    printstyled(io, "… "; color = :light_black)
                    print(io, " ")
                    dump_elts_delim_array(recur_io, x, n, indent, lx - 4, lx)
                end
            else
                dump_elts_delim_array(recur_io, x, n, indent, 1, lx)
            end
            printstyled("]"; color = :light_yellow)
        end
    else # if x isa Memory || eltype(x) <: Number
        if n > 0 && !isempty(x) && !show_circular(io, x)
            println(io)
            recur_io = IOContext(io, :SHOWN_SET => x)
            lx = length(x)
            if get(io, :limit, false)::Bool
                dump_elts_x(recur_io, x, n, indent, 1, (lx <= 10 ? lx : 5))
                if lx > 10
                    println(io)
                    print(io, indent, "  ")
                    printstyled(io, "… "; color = :light_black)
                    println(io)
                    dump_elts_x(recur_io, x, n, indent, lx - 4, lx)
                end
            else
                dump_elts_x(recur_io, x, n, indent, 1, lx)
            end
        end
    end
    nothing
end

# from julia/base/show.jl  function dump(io::IOContext, x::DataType, n::Int, indent)
using Base: _NAMEDTUPLE_NAME, datatype_fieldtypes
function dump_x(io::IOContext, x::DataType, n::Int, indent)
    # For some reason, tuples are structs
    is_struct = isstructtype(x) && !(x <: Tuple)
    is_mut = is_struct && ismutabletype(x)
    is_mut && printstyled(io, "mutable "; color = :light_yellow)
    is_struct && printstyled(io, "struct "; color = :light_yellow)
    isprimitivetype(x) && printstyled(io, "primitive type "; color = :light_yellow)
    isabstracttype(x) && printstyled(io, "abstract type "; color = :light_yellow)
    printstyled(io, x; color = :green)
    if x !== Any
        print(io, " ")
        printstyled(io, "<:"; color = :light_yellow)
        print(io, " ")
        print(io, highlight(supertype(x)))
    end
    if n > 0 && !(x <: Tuple) && !isabstracttype(x)
        tvar_io::IOContext = io
        for tparam in x.parameters
            # approximately recapture the list of tvar parameterization
            # that may be used by the internal fields
            if isa(tparam, TypeVar)
                tvar_io = IOContext(tvar_io, :unionall_env => tparam)
            end
        end
        if x.name === _NAMEDTUPLE_NAME && !(x.parameters[1] isa Tuple)
            # named tuple type with unknown field names
            return
        end
        fields = fieldnames(x)
        fieldtypes = datatype_fieldtypes(x)
        for idx in eachindex(fields)
            println(io)
            print(io, indent, "  ")
            is_mut && isconst(x, idx) && print(io, "const ")
            print(io, fields[idx])
            if isassigned(fieldtypes, idx)
                printstyled(io, "::"; color = :light_black)
                print(tvar_io, highlight(fieldtypes[idx]))
            end
        end
    end
    nothing
end

# from julia/base/show.jl  function dump(io::IOContext, @nospecialize(x), n::Int, indent)
function dump_object(io::IOContext, @nospecialize(x), n::Int, indent)
    if x === Union{}
        show(io, x)
        return
    end
    T = typeof(x)
    if isa(x, Function)
        print(io, highlight(T), "  ")
        printstyled(io, x; color = :cyan)
    else
        if in_julia_core(parentmodule(T))
            print(io, highlight(T))
        else
            printstyled(io, T; color = :green)
        end
    end
    nf = nfields(x)
    if nf > 0
        if n > 0 && !show_circular(io, x)
            recur_io = IOContext(io, Pair{Symbol,Any}(:SHOWN_SET, x))
            for field in 1:nf
                println(io)
                print(io, indent, "  ")
                field_name = fieldname(T, field)
                if field == field_name
                    printstyled(io, field; color = :light_cyan)
                    printstyled(io, ": "; color = :light_black)
                else
                    print(io, field_name)
                    printstyled(io, "::"; color = :light_black)
                end
                if isdefined(x, field)
                    dump_x(recur_io, getfield(x, field), n - 1, string(indent, "  "))
                else
                    print(io, highlight(undef_ref_str))
                end
            end
        end
    elseif !isa(x, Function)
        print(io, "  ")
        print(io, highlight(x))
    end
    nothing
end

# `dump` overrided by indent::String
import Base: dump
function dump(io::IOContext, x::Module, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::Symbol, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::AbstractChar, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::Bool, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::Array, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::String, n::Int, indent::String)
    dump_x(io, x, n, indent) # @nospecialize(x)
end

function dump(io::IOContext, x::DataType, n::Int, indent::String)
    dump_x(io, x, n, indent)
end

function dump(io::IOContext, x::AbstractString, n::Int, indent::String)
    dump_object(io, x, n, indent) # @nospecialize(x)
end

function dump(io::IOContext, x::Expr, n::Int, indent::String)
    dump_object(io, x, n, indent)
end

function dump(io::IOContext, @nospecialize(x), n::Int, indent::String)
    dump_object(io, x, n, indent)
end

# module DumpTruck
