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
v = rand(1:100, 10)
inds = axes(v,1)
println(v)
sa.adaptative_partition!(v, 0.2, first(inds), last(inds), Base.Order.Forward)
println("\n===================\n")
println(v)
sa.default_quicksort!(v)
println(v)