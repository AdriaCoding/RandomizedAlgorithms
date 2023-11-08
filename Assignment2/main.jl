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
export 
default_quicksort!
end;

import .SelectionAlgs as sa;
using .SelectionAlgs, BenchmarkTools;