module Cardinality

export HyperLogLog, MyHyperLogLog, MyKMV

include("hyperloglog/hyperloglog.jl")
include("myhyperloglog.jl")
include("KMV.jl")

using BenchmarkTools, DataStructures
end
import .Cardinality as ca

function get_ds_cardinality(obj, filename)
    # obj has to be empty
    isempty(obj) || throw(ArgumentError("Maquina, Mechatron, gavilan, que el 'obj' no esta vacío..."))
    open(filename) do file
        for word in eachline(file)
            push!(obj, word)
        end
    end
    return length(obj)
end

function synthetic_ds(n, N, α)
    n < N ||
        throw(ArgumentError("In synthetic_ds the alphabet has to be smaller than the data stream size. Perhaps switch the arguments order"))
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
global KMV_k = 1<<HLL_mem
global real_N = [] #[3185, 23134, 5893, 5760, 9517, 6319, 8995, 550501, 17620]
s = Set{String}()
hll = ca.HyperLogLog{HLL_mem}()
kmv = ca.MyKMV() #
synthetic_ds(150, 10000, 1)
println("MyH->", get_ds_cardinality(ca.MyHyperLogLog{HLL_mem}(), "Assignment3/datasets/D1.dat"))
println("HLL->", get_ds_cardinality(ca.HyperLogLog{HLL_mem}(), "Assignment3/datasets/D1.dat"))
println("KMV->", get_ds_cardinality(ca.MyKMV{KMV_k}(), "Assignment3/datasets/D1.dat"))
println("Set->", get_ds_cardinality(ca.Set{String}(), "Assignment3/datasets/D1.dat"))

objs = [("MyHLL", ca.MyHyperLogLog{HLL_mem}()), ("KMV", ca.MyKMV{KMV_k}())]
filenames = ["Assignment3/datasets/D$i.dat" for i in 1:3]

function compare_table(filenames, objs)
    for (name, obj) in objs
        res = get_ds_cardinality(obj, filenames[1])
    end
end
compare_table(filenames, objs)
