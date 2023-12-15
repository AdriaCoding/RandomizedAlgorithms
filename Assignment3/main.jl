module Cardinality

export HyperLogLog, MyHyperLogLog, MyKMV

import Pkg; Pkg.add("CSV"), Pkg.add("Tables"), Pkg.add("XXhash")
using BenchmarkTools, DataStructures, CSV, Tables, XXhash

include("algorithms/hyperloglog.jl")
include("algorithms/myhyperloglog.jl")
include("algorithms/KMV.jl")
include("algorithms/xKMV.jl")
include("algorithms/xHLL.jl")

end
import .Cardinality as ca

function get_ds_cardinality(obj, filename)
    # obj has to be empty
    empty!(obj)
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
println("Cardinality estimation fot the first dataset (real value = $(get_ds_cardinality(ca.Set{String}(), "Assignment3/datasets/D1.dat")))")

println("MyH->", get_ds_cardinality(ca.MyHyperLogLog{HLL_mem}(), "Assignment3/datasets/D1.dat"))
println("HLL->", get_ds_cardinality(ca.HyperLogLog{HLL_mem}(), "Assignment3/datasets/D1.dat"))
println("KMV->", get_ds_cardinality(ca.MyKMV{KMV_k}(), "Assignment3/datasets/D1.dat"))

function compare_table(nfiles, mem)
    kmvmem = 1 << mem
    objs = [Set{String}(),
        ca.HyperLogLog{mem}(),
        ca.MyHyperLogLog{mem}(),
        ca.MyKMV{kmvmem}(),
        ]
    objnames = ["Real" "MyHLL" "KMV" "HLL"] 
    M = ["D$i" for i in 1:nfiles]
    filenames = ["Assignment3/datasets/D$i.dat" for i in 1:nfiles]
    for obj in objs
        res = map(x->get_ds_cardinality(obj, x), filenames)
        M = hcat(M, res)
    end
    M = vcat(["Struct" objnames], M)
    CSV.write("Assignment3/results/DS_comparison_$mem.csv",
        Tables.table(M), writeheader=false)
    return M
end
nfiles = 9
compare_table(nfiles, 4)
compare_table(nfiles, 18)
