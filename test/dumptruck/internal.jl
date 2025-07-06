module test_dumptruck_internal

using Test
using DumpTruck: _print_type

io = IOContext(stdout)
@test _print_type(io, :(unreachable)) === nothing

end # module test_dumptruck_internal
