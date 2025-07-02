module test_dumptruck_advanced

using Test
using REPL
include(normpath(@__DIR__, "../helper/helpers.jl"))

@dump_object fill(0, 1000)
@dump_object collect('🚚':'🚚'+5)
@dump_object Dict(:k => :v)
@dump_object REPL.REPLCompletions.latex_symbols
@dump_object keys(REPL.REPLCompletions.latex_symbols)

end # module test_dumptruck_advanced
