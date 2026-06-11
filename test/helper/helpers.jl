using DumpTruck

if !isdefined(@__MODULE__, :dump_expr)

function dump_expr(x::Expr)
    printstyled("dump"; color = :cyan)
    print("(")
    print(DumpTruck.highlight(stdout, x))
    print(")")
    println()
    dump(x)
    println()
end

macro dump_object(@nospecialize(x))
    printstyled("dump"; color = :cyan)
    print("(")
    print(x)
    print(")")
    println()
    dump(eval(x))
    println()
end

end # if
