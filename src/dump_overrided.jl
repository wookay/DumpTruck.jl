# module DumpTruck

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
