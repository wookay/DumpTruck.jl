# DumpTruck.jl 🚚

[![CI](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml/badge.svg)](https://github.com/wookay/DumpTruck.jl/actions/workflows/actions.yml)

highlight the `dump` function.
Requires Julia v1.12.
See the [github actions logs](https://github.com/wookay/DumpTruck.jl/actions/runs/16075729041/job/45370395308#step:6:102).

<img src="https://raw.github.com/wookay/DumpTruck.jl/main/docs/images/dump.png" alt="DumpTruck.dump" width="436" height="430">

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

julia> dump(supertypes(Int))
NTuple{6, DataType}
  1: primitive type Int64 <: Signed
  2: abstract type Signed <: Integer
  3: abstract type Integer <: Real
  4: abstract type Real <: Number
  5: abstract type Number <: Any
  6: abstract type Any
```
