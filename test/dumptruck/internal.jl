module test_dumptruck_internal

using Test
using DumpTruck: _print_type, takestring!

@test get(IOContext(stdout, :color => true), :color, false) === true
@test get(IOContext(stdout, :color => false), :color, true) === false

@test get(IOContext(stdout), :color, true) === true
@test get(IOContext(stdout), :color, false) === (Base.JLOptions().color != 2 #= no =#)

io_context = IOContext(stdout, :color => false)
@test _print_type(io_context, :(unreachable)) === nothing

buf = IOBuffer()
_print_type(IOContext(buf, :color => false), DataType.types)
@test takestring!(buf) == "Core.SimpleVector"

_print_type(IOContext(buf, :color => false), "hello")
@test takestring!(buf) == "String"

_print_type(IOContext(buf, :color => true), "hello")
@test takestring!(buf) == "\e[33mString\e[39m"

_print_type(IOContext(buf, :color => false), "hello")
@test takestring!(buf) == "String"

end # module test_dumptruck_internal
