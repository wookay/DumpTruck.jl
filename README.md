# DumpTruck.jl 🚚

[![CI](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml/badge.svg)](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml)

highlight the `dump` function.
Requires Julia v1.12.
See the [github actions logs](https://github.com/wookay/DumpTruck.jl/actions/runs/16083570456/job/45391633345#step:6:102).

<img src="https://raw.github.com/wookay/DumpTruck.jl/main/docs/images/dump.png" alt="DumpTruck.dump" width="465" height="426">

```julia
julia> using DumpTruck

julia> dump(:(1 + 2 * 3))
Expr
  head::Symbol  :call
  args::Vector{Any}  length = 3
    1: Symbol  :+
    2: Int64  1
    3: Expr
      head::Symbol  :call
      args::Vector{Any}  length = 3
        1: Symbol  :*
        2: Int64  2
        3: Int64  3
```
