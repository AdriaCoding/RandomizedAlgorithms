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
include("se_sesquickselect.jl")

export default_quicksort!, adaptative_partition!
end

import .SelectionAlgs as sa;

n = 10; w = rand(1:10, n); m=rand(1:n);
𝓢 = sa.sesquickselect!(w, m, 0)
println("number of scanned elements: $𝓢")
#DEBUG ONLY

 error = 0;
for iter in 1:500000
    n = 10; w = rand(1:10, n); m=rand(1:n);
    ñ = sa.sesquickselect!(w, m)
    sort!(w)
    if w[m] != ñ; global error += 1
        println(iter, "\n====================\n");
    end
end
println("\n================================================================ \nErrors commited: ", error) 