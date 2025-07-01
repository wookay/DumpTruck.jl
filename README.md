# DumpTruck.jl 🚚

[![CI](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml/badge.svg)](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml)

highlight `dump(::Expr)`. requires Julia v1.12

```julia
julia> using DumpTruck

julia> dump(:(1 + 2 * 3))
Expr
  head: Symbol  :call
  args: Array{Any}  size = (3,)
    1: Symbol  :+
    2: Int64  1
    3: Expr
      head: Symbol  :call
      args: Array{Any}  size = (3,)
        1: Symbol  :*
        2: Int64  2
        3: Int64  3
```
