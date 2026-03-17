# check_for_updates_using_sugar_cubes.jl
#
# ~/.julia/dev/DumpTruck main✔   ln -s  JULIA_SOURCE_PATH  sources

using Test
using SugarCubes: code_block_with, has_diff
# https://github.com/wookay/SugarCubes.jl

function check_the_code_block_diff(src_path::String,
                                   src_signature::Expr,
                                   dest_path::String,
                                   dest_signature::Expr ;
                                   skip_lines = (src = Int[], dest = Int[]))
    printstyled(stdout, "check_the_code_block_diff", color = :blue)
    print(stdout, " ", basename(src_path), " ")
    src_filepath = normpath(@__DIR__, "..", src_path)
    dest_filepath = normpath(@__DIR__, "..", dest_path)
    @test isfile(src_filepath)
    @test isfile(dest_filepath)
    src_block = code_block_with(; filepath = src_filepath, signature = src_signature)
    (depth, kind, sig) = src_block.signature.layers[end]
    printstyled(stdout, sig.args[1], color = :cyan)
    dest_block = code_block_with(; filepath = dest_filepath, signature = dest_signature)
    @test has_diff(src_block, dest_block; skip_lines) === false
    println(stdout)
end

check_the_code_block_diff(
    "sources/base/show.jl",
    :(function dump(io::IOContext, x::DataType, n::Int, indent) end),
    "src/show_customized.jl",
    :(function dump_x(io::IOContext, x::DataType, n::Int, indent) end) ;
    skip_lines = (src = vcat(4:8, 10, 26, 32:34), dest = vcat(1:3, 7:11, 13:20, 36, 42:44, 47:58))
)

check_the_code_block_diff(
    "sources/base/show.jl",
    :(function dump_elts(io::IOContext, x::Array, n::Int, indent, i0, i1) end),
    "src/show_customized.jl",
    :(function dump_elts_x(io::IOContext, x::Array, n::Int, indent, i0, i1) end) ;
    skip_lines = (src = [2], dest = vcat(2:4))
)
