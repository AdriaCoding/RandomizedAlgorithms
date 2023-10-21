module RandomPi
# Only once, load all the potentilly necessary libraries
import Pkg;
Pkg.add("DataStructures") # otherwise count() can bug
Pkg.add("BenchmarkTools"); #used to test out performance
Pkg.add("Plots");
Pkg.add("LaTeXStrings"); #used for cooler plots
using DataStructures, BenchmarkTools, Plots, LaTeXStrings; 

# Include all the functions in the project
include("../Assingment1/darts.jl")
include("../Assingment1/buffon.jl")
include("../Assingment1/plots.jl")
export fast_darts
export fast_buffon
export plot_everything
end;

import .RandomPi as rp;



#@time plot_err(4, master_buffon)