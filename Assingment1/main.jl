include("../Assingment1/dart_functions.jl")
include("../Assingment1/buffon_functions.jl")
using BenchmarkTools
N = 10^6
#π1 = time_darts(N)
#π2 = time_fast_darts(N)
#π3 = time_faster_darts(N)
#π4 = time_opt_darts(N)
#π5 = time_online_darts(N)çç
#π6 = time_map_darts(N)
π7 = @time master_dart(N)
π8 = @time 4.0* piecewise_dart(N)/N
#println(π7, ":", π8)
#println("online_darts benchmark")
#@benchmark online_darts(N)
#println("map_darts benchmark")
#@benchmark map_darts(N)
# @code_lowered darts_pi(N)
# @code_lowered darts_pi(N)
# @code_lowered fast_darts(N)
# @code_lowered faster_darts(N)
# @code_lowered opt_darts(N)
#@code_lowered online_darts(N)