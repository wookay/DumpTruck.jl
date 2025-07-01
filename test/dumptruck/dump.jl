module test_dumptruck_dump

using Test
using DumpTruck
using Jive

function dump_expr(x::Expr)
    printstyled("dump"; color = :cyan)
    print("(")
    print(highlight(x))
    print(")")
    println()
    dump(x)
    println()
end

macro dump_object(@nospecialize(x))
    printstyled("dump"; color = :cyan)
    print("(")
    if eval(x) isa String
        print(highlight(repr(x)))
    else
        print(highlight(string(x)))
    end
    print(")")
    println()
    dump(eval(x))
    println()
end

dump_expr(  :(1 + 2)        )
dump_expr(  :(1 + (2 * 3))  )
@dump_object "hello"
@dump_object SubString("hello")
@dump_object [1, 2, 3]


@test true

end # module test_dumptruck_dump
