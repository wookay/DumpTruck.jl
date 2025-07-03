using Jive
@useinside Main module test_dumptruck_basic

using Test
include(normpath(@__DIR__, "../helper/helpers.jl"))

dump_expr(:(1 + 2))
dump_expr(:(1 + (2 * 3)))

@dump_object "hello"
@dump_object SubString("hello")
@dump_object '🚚'
@dump_object true
@dump_object false
@dump_object nothing
@dump_object Nothing
@dump_object 1 + 2
@dump_object pi
@dump_object sum
@dump_object [1, 2, 3]
@dump_object (1, 2, 3)
@dump_object (; k=:v)
@dump_object :k => :v
@dump_object `ls`
@dump_object Core

abstract type Animal end
@dump_object Animal

struct Dog <: Animal
    breed::String
end
@dump_object Dog

dalmatian = Dog("Dalmatian")
@dump_object dalmatian

husky = Dog("Siberian Husky")
@dump_object husky


@test true

end # module test_dumptruck_basic
