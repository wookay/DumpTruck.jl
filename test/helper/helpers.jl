using DumpTruck

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
    if eval(x) isa String
        print(DumpTruck.highlight(stdout, repr(x)))
    else
        print(DumpTruck.highlight(stdout, string(x)))
    end
    print(")")
    println()
    dump(eval(x))
    println()
end
