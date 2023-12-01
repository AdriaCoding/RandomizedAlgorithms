module Cardinality
export HyperLogLog
include("hyperloglog/hyperloglog.jl")
using Probably, BenchmarkTools
end
#=
N = 2^8; P = 14
hll = HyperLogLog{P}()
for i in 1:N; push!(hll, i); end
length(hll) - N
 =#
using BenchmarkTools

global HLL_mem = 10 # HyperLogLog will have 2^HLL_mem bytes of memory
global real_N = [] #[3185, 23134, 5893, 5760, 9517, 6319, 8995, 550501, 17620

s = Set{String}()
hll = HyperLogLog{HLL_mem}()


function get_cardinality(obj, filename)
    # obj has to be empty
    if length(obj) > 1
        throw("Maquina, Mechatron, gavilan, que el 'obj' no esta vacío...")
    end
    file = open(filename)
    for word in eachline(file)
        push!(obj, word)
    end
    return length(obj)
end
println(length(hll))
@btime get_cardinality(HyperLogLog{HLL_mem}(), "datasets/D8.dat")
@btime get_cardinality(Set{String}(), "datasets/D8.dat")