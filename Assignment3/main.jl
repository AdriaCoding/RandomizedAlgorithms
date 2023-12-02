module Cardinality
export HyperLogLog
include("hyperloglog/hyperloglog.jl")
using BenchmarkTools
end
#=
N = 2^8; P = 14
hll = HyperLogLog{P}()
for i in 1:N; push!(hll, i); end
length(hll) - N
 =#
using .Cardinality

global HLL_mem = 10 # HyperLogLog will have 2^HLL_mem bytes of memory
global real_N = [] #[3185, 23134, 5893, 5760, 9517, 6319, 8995, 550501, 17620
s = Set{String}()
hll = HyperLogLog{HLL_mem}()


function get_ds_cardinality(obj, filename)
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
@btime get_ds_cardinality(HyperLogLog{HLL_mem}(), "datasets/D8.dat")
@btime get_ds_cardinality(Set{String}(), "datasets/D8.dat")


function synthetic_ds(n, N, α)
    if (n > N) 
        throw("In synthetic_ds the alphabet has to be smaller than the data stream size. Perhaps switch the arguments order")
    end
    alphabet = 1:n
    cn = 0
    for i in 1:n; c+=i^α; end
    cn = 1/cn
    weigths = [cn/(i^α) for i in 1:n]
    synthetic = Array{Int}(undef, N) 
    for i in 1:N

    end
    
end

function sample(a, weights)
    1 == firstindex(weights) ||
        throw(ArgumentError("non 1-based arrays are not supported"))
    t = rand(rng) * sum(weights)
    n = length(weights)
    i = 1
    cw = weights[1]
    while cw < t && i < n
        i += 1
        @inbounds cw += weights[i]
    end
    return i
end
