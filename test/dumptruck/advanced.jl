module test_dumptruck_advanced

using Test
include(normpath(@__DIR__, "../helper/helpers.jl"))
using REPL
using .REPL.InteractiveUtils: supertypes

@dump_object supertypes(Int)
@dump_object fill(0, 1000)
@dump_object '🚚':'🚚'+5
@dump_object collect('🚚':'🚚'+5)
@dump_object Dict(:k1 => :v1, :k2 => :v2)
@dump_object REPL.REPLCompletions.latex_symbols
@dump_object keys(REPL.REPLCompletions.latex_symbols)

@dump_object Union{}
@dump_object Union
@dump_object UnionAll

TypeT = supertype(Union)
@dump_object TypeT

@test TypeT.parameters[1] isa TypeVar
@test supertype(Union) === TypeT
@test supertype(UnionAll) === TypeT
@test (Type{T} where T) isa UnionAll
@test supertype(Type{T} where T) === Any

@dump_object Type{T} where T

end # module test_dumptruck_advanced
