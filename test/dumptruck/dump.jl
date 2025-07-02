using Jive
@useinside Main module test_dumptruck_dump

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
@dump_object '🚚'
@dump_object true
@dump_object 1 + 2
@dump_object pi
@dump_object [1, 2, 3]
@dump_object sum
@dump_object (1, 2, 3)
@dump_object (; k = :v)
@dump_object :k => :v
@dump_object Dict(:k => :v)
@dump_object `ls`
@dump_object Core

struct Animal
    field
end
dog = Animal(1)
@dump_object dog

@test true

end # module test_dumptruck_dump
