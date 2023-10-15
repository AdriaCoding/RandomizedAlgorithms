include("../Assingment1/darts.jl")
include("../Assingment1/buffon.jl")

using Pkg
Pkg.add("DataStructures") # otherwise count() is bugged
using BenchmarkTools #used to test out performance
N = 10^6

fast_darts(10^6)
pi1 = @btime master_dart(N, 10^6)
pi2 = @btime teste_dart(N, 10^6)


