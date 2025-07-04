module test_dumptruck_advanced

using Test
include(normpath(@__DIR__, "../helper/helpers.jl"))
using REPL
using .REPL.InteractiveUtils: supertypes

@dump_object Union{}
@dump_object Union
@dump_object supertypes(Int)
@dump_object fill(0, 1000)
@dump_object '🚚':'🚚'+5
@dump_object collect('🚚':'🚚'+5)
@dump_object Dict(:k1 => :v1, :k2 => :v2)
@dump_object REPL.REPLCompletions.latex_symbols
@dump_object keys(REPL.REPLCompletions.latex_symbols)

end # module test_dumptruck_advanced
