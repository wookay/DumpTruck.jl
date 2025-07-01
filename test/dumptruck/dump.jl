using DumpTruck

function dump_expr(expr::Expr; LF::Bool = true)
    printstyled("dump"; color = :cyan)
    println("(", highlight(expr), ")")
    dump(expr)
    LF && println()
end

dump_expr(  :(1 + 2)        )
dump_expr(  :(1 + (2 * 3))  , LF = false)


using Test
@test true
