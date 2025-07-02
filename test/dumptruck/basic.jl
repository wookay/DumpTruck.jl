using Jive
@useinside Main module test_dumptruck_basic

using Test
include(normpath(@__DIR__, "../helper/helpers.jl"))

dump_expr(  :(1 + 2)        )
dump_expr(  :(1 + (2 * 3))  )

@dump_object "hello"
@dump_object SubString("hello")
@dump_object '🚚'
@dump_object true
@dump_object false
@dump_object 1 + 2
@dump_object pi
@dump_object sum
@dump_object [1, 2, 3]
@dump_object (1, 2, 3)
@dump_object (; k = :v)
@dump_object :k => :v
@dump_object `ls`
@dump_object Core

struct Animal
    field
end
dog = Animal(1)
@dump_object Animal
@dump_object dog


@test true

end # module test_dumptruck_basic
