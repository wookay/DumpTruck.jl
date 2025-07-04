# module DumpTruck

# `dump` overrided by indent::String
import Base: dump

# from julia/base/show.jl  (ambiguous)
dump(io::IOContext, x::Module, n::Int, indent::String)        = dump_x(io, x, n, indent)
dump(io::IOContext, x::String, n::Int, indent::String)        = dump_x(io, x, n, indent)
dump(io::IOContext, x::Symbol, n::Int, indent::String)        = dump_x(io, x, n, indent)
dump(io::IOContext, x::Union, n::Int, indent::String)         = dump_x(io, x, n, indent)
dump(io::IOContext, x::Ptr, n::Int, indent::String)           = dump_x(io, x, n, indent)
dump(io::IOContext, x::Array, n::Int, indent::String)         = dump_x(io, x, n, indent)
dump(io::IOContext, x::DataType, n::Int, indent::String)      = dump_x(io, x, n, indent)
dump(io::IOContext, @nospecialize(x), n::Int, indent::String) = dump_x(io, x, n, indent)

# module DumpTruck
