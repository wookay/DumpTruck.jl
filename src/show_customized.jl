# module DumpTruck

function _in_julia_core(m::Union{Module, DataType})
    m in (Core, Base)
end

function _print_type(io::IOContext, @nospecialize(x))
    get(io, :PRINTED, :(unreachable)) === x && return
    T = typeof(x)
    if get(io, :color, true)
        if _in_julia_core(parentmodule(T))
            print(io, highlight(T))
        else
            printstyled(io, T; color = :green)
        end
    else
        print(io, repr(T))
    end
end


### dump_x (overrided)

# from julia/base/show.jl  dump(io::IOContext, x::Module, n::Int, indent)
function dump_x(io::IOContext, x::Module, n::Int, indent)
    _print_type(io, x)
    print(io, "  ")
    if _in_julia_core(x)
        printstyled(io, x; color = :light_blue)
    else
        printstyled(io, x; color = :green)
    end
    nothing
end

# from julia/base/show.jl  dump(io::IOContext, x::String, n::Int, indent)
function dump_x(io::IOContext, x::String, n::Int, indent)
    _print_type(io, x)
    print(io, "  ")
    print(io, highlight(repr(x)))
end

# from julia/base/show.jl  function dump(io::IOContext, x::Array, n::Int, indent)
using Base: show_circular, dump_elts
function dump_x(io::IOContext, x::Array, n::Int, indent)
    _print_type(io, x)
    print(io, "  ")
    if x isa Vector
        print(io, "length = ", highlight(length(x)))
    else
        print(io, "size = ", highlight(size(x)))
    end
    if eltype(x) <: Number
        if n > 0 && !isempty(x) && !show_circular(io, x)
            print(io, "  ")
            printstyled("["; color = :light_yellow)
            recur_io = IOContext(io, :SHOWN_SET => x)
            lx = length(x)
            if get(io, :limit, false)::Bool
                dump_elts_delim_array(recur_io, x, n, indent, 1, (lx <= dumptruck_limit_full ? lx : dumptruck_limit_half))
                if lx > dumptruck_limit_full
                    print(io, ", ")
                    printstyled(io, "… "; color = :light_black)
                    print(io, " ")
                    dump_elts_delim_array(recur_io, x, n, indent, lx - (dumptruck_limit_half - 1), lx)
                end
            else
                dump_elts_delim_array(recur_io, x, n, indent, 1, lx)
            end
            printstyled("]"; color = :light_yellow)
        end
    else # if eltype(x) <: Number
        if n > 0 && !isempty(x) && !show_circular(io, x)
            println(io)
            recur_io = IOContext(io, :SHOWN_SET => x)
            lx = length(x)
            if get(io, :limit, false)::Bool
                dump_elts_x(recur_io, x, n, indent, 1, (lx <= dumptruck_limit_full ? lx : dumptruck_limit_half))
                if lx > dumptruck_limit_full
                    println(io)
                    print(io, indent, "  ")
                    printstyled(io, "… "; color = :light_black)
                    println(io)
                    dump_elts_x(recur_io, x, n, indent, lx - (dumptruck_limit_half - 1), lx)
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
    if get(io, :PRINTED, :(unreachable)) === x
        print(io, "  ")
    end
    # For some reason, tuples are structs
    is_struct = isstructtype(x) && !(x <: Tuple)
    is_mut = is_struct && ismutabletype(x)
    is_mut && printstyled(io, "mutable "; color = :light_yellow)
    is_struct && printstyled(io, "struct "; color = :light_yellow)
    isprimitivetype(x) && printstyled(io, "primitive type "; color = :light_yellow)
    isabstracttype(x) && printstyled(io, "abstract type "; color = :light_yellow)
    printstyled(io, x; color = :light_green)
    if x !== Any
        print(io, " ")
        printstyled(io, "<:"; color = :light_yellow)
        print(io, " ")
        if _in_julia_core(supertype(x))
            print(io, highlight(supertype(x)))
        else
            printstyled(io, supertype(x); color = :light_green)
        end
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
        _field_types = datatype_fieldtypes(x)
        for idx in eachindex(fields)
            println(io)
            print(io, indent, "  ")
            is_mut && isconst(x, idx) && print(io, "const ")
            print(io, fields[idx])
            if isassigned(_field_types, idx)
                printstyled(io, "::"; color = :light_black)
                print(tvar_io, highlight(_field_types[idx]))
            end
        end
    elseif get(io, :SHOWN_SET, nothing) === nothing
        for name in propertynames(x)
            name === :instance && continue
            println(io)
            print(io, indent, "  ")
            print(io, name)
            printstyled(io, "::"; color = :light_black)
            prop = getproperty(x, name)
            print(io, highlight(typeof(prop)))
            print(io, "  ")
            print(io, highlight(prop))
        end
    end
    nothing
end

function dump_x(io::IOContext, x::Function, n::Int, indent)
    T = typeof(x)
    print(io, highlight(T))
    dump_object(io, x, n, indent)
end

# from julia/base/show.jl  dump(io::IOContext, @nospecialize(x), n::Int, indent)
using Base: undef_ref_str
function dump_x(io::IOContext, @nospecialize(x), n::Int, indent)
    _print_type(io, x)
    dump_object(io, x, n, indent)
end

# called from dump_object
function dump_field(io::IOContext, x, n::Int, indent, T, field::Int)
    _field_types = fieldtypes(T)
    T = _field_types[field]
    print(io, highlight(T))
    xfield = getfield(x, field)
    recur_io = IOContext(io, :PRINTED => xfield)
    dump_x(recur_io, xfield, n - 1, string(indent, "  "))
end

# from julia/base/show.jl  dump(io::IOContext, @nospecialize(x), n::Int, indent)
function dump_object(io::IOContext, @nospecialize(x), n::Int, indent)
    nf = nfields(x)
    if nf > 0
        if n > 0 && !show_circular(io, x)
            recur_io = IOContext(io, Pair{Symbol,Any}(:SHOWN_SET, x))
            T = typeof(x)
            for field in 1:nf
                println(io)
                print(io, indent, "  ")
                field_name = fieldname(T, field)
                if field == field_name # Int
                    printstyled(io, field; color = :light_cyan)
                    printstyled(io, ": "; color = :light_black)
                else
                    print(io, field_name)
                    printstyled(io, "::"; color = :light_black)
                end
                if isdefined(x, field)
                    dump_field(recur_io, x, n - 1, indent, T, field)
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


# dump_x (customized)

function dump_x(io::IOContext, x::Core.TypeofBottom, n::Int, indent) # x === Union{}
    print(io, highlight(x))
    nothing
end

function dump_x(io::IOContext, x::Bool, n::Int, indent)
    _print_type(io, x)
    print(io, "  ")
    printstyled(io, x; color = x ? :light_green : :light_red)
    nothing
end

function dump_x(io::IOContext, x::AbstractChar, n::Int, indent)
    _print_type(io, x)
    print(io, "  ")
    if isdefined(REPL, :show_repl)
        REPL.show_repl(io, MIME("text/plain"), x)
    else
        show(io, "text/plain", x)
    end
    nothing
end

const dumptruck_limit_half = 3 # 5
const dumptruck_limit_full = 2 * dumptruck_limit_half

# from julia/base/show.jl  function dump(io::IOContext, x::Array, n::Int, indent)
function dump_x(io::IOContext, x::AbstractDict{K,V}, n::Int, indent) where {K,V}
    _print_type(io, x)
    print(io, "  ")
    print(io, "length = ", highlight(length(x)))
    if n > 0 && !isempty(x)
        recur_io = IOContext(io, :SHOWN_SET => x)
        lx = length(x)
        println(io)
        print(io, indent, "  ")
        printstyled("("; color = :light_blue)
        dict_keys = collect(keys(x))
        if get(io, :limit, false)::Bool
            dump_elts_delim_dict(recur_io, x, n, indent, 1, (lx <= dumptruck_limit_full ? lx : dumptruck_limit_half), dict_keys)
            if lx > dumptruck_limit_full
                print(io, ", ")
                printstyled(io, "… "; color = :light_black)
                print(io, " ")
                dump_elts_delim_dict(recur_io, x, n, indent, lx - (dumptruck_limit_half - 1), lx, dict_keys)
            end
        else
            dump_elts_delim_dict(recur_io, x, n, indent, 1, lx, dict_keys)
        end
        printstyled(")"; color = :light_blue)
    end
    if get(io, :SHOWN_SET, nothing) === nothing
        dump_object(io, x, n, indent)
    end
    nothing
end

function dump_x(io::IOContext, x::LineNumberNode, n::Int, indent)
    _print_type(io, x)
    if x.file isa Symbol
        file = Symbol(contractuser(String(x.file)))
        lnn = LineNumberNode(x.line, file)
    else
        lnn = x
    end
    printstyled(io, highlight(lnn))
    nothing
end


### dump_elts

# from julia/base/show.jl  function dump_elts(io::IOContext, x::Array, n::Int, indent, i0, i1)
function dump_elts_x(io::IOContext, x::Array, n::Int, indent, i0, i1)
    for i in i0:i1
        print(io, indent, "  ")
        printstyled(io, i; color = :light_cyan)
        print(io, ": ")
        if !isassigned(x,i)
            print(io, highlight(undef_ref_str))
        else
            dump_x(io, x[i], n - 1, string(indent, "  "))
        end
        i < i1 && println(io)
    end
end

function dump_elts_delim_array(io::IOContext, x, n::Int, indent, i0, i1)
    for i in i0:i1
        if !isassigned(x, i)
            print(io, highlight(undef_ref_str))
        else
            print(io, highlight(x[i]))
        end
        i < i1 && print(io, ", ")
    end
end

function dump_elts_delim_dict(io::IOContext, x::AbstractDict{K,V}, n::Int, indent, i0, i1, dict_keys) where {K,V}
    for i in i0:i1
        k = dict_keys[i]
        v = x[k]
        print(io, highlight(k => v))
        i < i1 && print(io, ", ")
    end
end

# module DumpTruck
