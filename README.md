# DumpTruck.jl 🚚

[![CI](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml/badge.svg)](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml)

highlight `dump(::Expr)`
Requires Julia v1.12.
See the [github actions logs](https://github.com/wookay/DumpTruck.jl/actions/runs/16014290117/job/45177890041#step:6:102).

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
