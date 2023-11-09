module SelectionAlgs
# Only once, load all the potentilly necessary libraries
#=
import Pkg;
Pkg.add("BenchmarkTools"); #used to test out performance
Pkg.add("Plots");
Pkg.add("LaTeXStrings"); #used for cooler plots
=#

using BenchmarkTools, Plots, LaTeXStrings, Base.Order; 

# Include all the functions in the project
include("sort_impl.jl")
include("sesquickselect.jl")
export default_quicksort!, adaptative_partition!
end

import .SelectionAlgs as sa;

#DEBUG ONLY
error = 0;
for _ in 1:100
    n = 10; v = rand(1:100, n); m=rand(1:n);
    inds = axes(v,1); 
    s = "Find element $m of : \n $v"
    ñ = sa.sesquickselect!(v, m)

    s = s* "\n ñ = $ñ\n$v\n"
    sort!(v)
    s = s*"$v"
    if v[m] != ñ; global error += 1
        println(s, "\n====================\n")
    end
end
println("\n================================================================ \nErrors commited: ", error)