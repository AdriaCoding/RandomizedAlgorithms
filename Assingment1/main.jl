include("../Assingment1/darts.jl")
include("../Assingment1/buffon.jl")
using BenchmarkTools

N = 10^6
pi1 = @btime master_dart(N*800, 10^6)
pi2 = @btime teste_dart(N*800, 10^6)
println(pi1, " ~ ", pi2)