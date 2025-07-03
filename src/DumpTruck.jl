module DumpTruck

using REPL

# highlight
include("highlight.jl")

# dump_elts
# dump_x
# dump_object
include("show_customized.jl")

# export dump
include("dump_overrided.jl")

end # module DumpTruck
