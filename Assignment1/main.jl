module RandomPi
# Only once, load all the potentilly necessary libraries
import Pkg;
Pkg.add("BenchmarkTools"); #used to test out performance
Pkg.add("Plots");
Pkg.add("LaTeXStrings"); #used for cooler plots
using BenchmarkTools, Plots, LaTeXStrings; 

# Include all the functions in the project
include("../Assignment1/darts.jl")
include("../Assignment1/buffon.jl")
include("../Assignment1/plots.jl")
export naive_darts, fast_darts, master_darts
export naive_buffon, fast_buffon, master_buffon
export plot_everything, plot_buffon, plot_dart, plot_err;
end;

import .RandomPi as rp;
using .RandomPi, BenchmarkTools;