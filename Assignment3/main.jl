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

function get_ds_cardinality(obj, filename)
    # obj has to be empty
    if length(obj) > 1
        throw("Maquina, Mechatron, gavilan, que el 'obj' no esta vacío...")
    end
    open(filename) do file
        for word in eachline(file)
            push!(obj, word)
        end
    end
    return length(obj)
end

function synthetic_ds(n, N, α)
    if (n > N) 
        throw("In synthetic_ds the alphabet has to be smaller than the data stream size. Perhaps switch the arguments order")
    end
    alphabet = 1:n
    cn = 0
    for i in 1:n; cn+=i^α; end
    cn = 1/cn
    weights = [cn/(i^α) for i in 1:n]
    synthetic = Array{Int}(undef, N) 
    sum_w = sum(weights)
    f = open("Assignment3/datasets/S$(n).dat", "w")
    for i in 1:N
        t = rand()*sum_w
        j = 1; cw = weights[1]
        while cw < t && j < n
            j += 1
            @inbounds cw += weights[j]
        end
        write(f, "$(alphabet[j])\n")
    end
    close(f)
end


global HLL_mem = 10 # HyperLogLog will have 2^HLL_mem bytes of memory
global real_N = [] #[3185, 23134, 5893, 5760, 9517, 6319, 8995, 550501, 17620]
s = Set{String}()
hll = HyperLogLog{HLL_mem}()
println(length(hll))
synthetic_ds(150, 10000, 1)
@time println(get_ds_cardinality(HyperLogLog{HLL_mem}(), "Assignment3/datasets/S135678.dat"))
@time println(get_ds_cardinality(Set{String}(), "Assignment3/datasets/S135678.dat"))
