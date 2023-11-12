module SelectionAlgorithms

export default_quicksort!, adaptative_partition!, 
get_scanned_elements, empirical_plot, f, shuffe;

# Only once, load all the potentilly necessary libraries

#= import Pkg;
Pkg.add("BenchmarkTools"); #used to test out performance
Pkg.add("Plots");
Pkg.add("LaTeXStrings"); #used for cooler plots
Pkg.add("Random"); #used for shuffle method
 =#
using BenchmarkTools, Plots, LaTeXStrings, Base.Order , Random;

# Include all the functions in the project
include("sort_impl.jl")
include("sesquickselect.jl")
include("plots.jl")
include("theoretical.jl")

end

import .SelectionAlgorithms as sa
using .SelectionAlgorithms

n = 30000; T = 100

##### To compute the plots like in the report
#sa.compute_and_plot(30000, 100, [0.1, 0.2, 0.2843, 0.3, 0.4, 0.5]) #Takes several seconds
#sa.compute_and_plot(30000, 1000, [0.1, 0.2, 0.2843, 0.3, 0.4, 0.5])
#sa.compute_and_plot(30000, 10000, [0.1, 0.2, 0.2843, 0.3, 0.4, 0.5]) #Takes +1h
 
#= ν = 0.2843; ν = 0.45
I, Sx, V = sa.get_scanned_elements(n, T, ν); 
println(sum(Sx)/length(Sx))
sa.empirical_plot(I, Sx, n, ν )
sa.variance_plot(I, V, n) =#

######## Check sesquickselct! correctness ad devault nu = 0.2843
#= 
error = 0; n=1000; T = 500
sorted = 1:n
for r in 1:T
    perm = sa.shuffle(sorted)
    v = copy(perm); i = rand(1:n)
    println("====================\nCalling sesquick with m=$i")
    element = sa.sesquickselect!(v, i)
    if sorted[i] != element; global error += 1
        println("ERROR $r: rank = $i\n",sorted, "\n",perm,"\n", v,element, "\n====================\n");
    end
end
println("\n ================================================================ \nErrors commited: ", error)

 =#