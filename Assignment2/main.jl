module SelectionAlgorithms

export default_quicksort!, quickselect!, shuffle,
compute_and_plot, empirical_plot,
sesquickselect!, single_partition!, double_partition!,
two_distinct_rng, select_two_pivots!, get_scanned_elements

# Only once, load all the potentially necessary libraries
import Pkg;
Pkg.add("Plots");
Pkg.add("Random"); #used for shuffle method

using Plots, Base.Order , Random;

# Include all the functions in the project
include("sort_impl.jl")
include("sesquickselect.jl")
include("plots.jl")
include("theoretical.jl")
end

import .SelectionAlgorithms as sa
using .SelectionAlgorithms # So you don't have to type "sa."


######## To compute the plots like in the report ########
#= sa.compute_and_plot(30000, 100,   [0.1, 0.2, 0.265, 0.3, 0.4, 0.5]) #Takes several seconds
sa.compute_and_plot(30000, 1000,  [0.1, 0.2, 0.265, 0.3, 0.4, 0.5])
sa.compute_and_plot(30000, 10000, [0.1, 0.2, 0.265, 0.3, 0.4, 0.5]) #Takes +1h
 =#
######## To compute a single plot for a value of nu ########
#= nu = 0.2; n = 3000; T = 100
I, Sx, V = sa.get_scanned_elements(n, T, nu); 
println(sum(Sx)/length(Sx))
sa.empirical_plot(I, Sx, n, nu )
=#

######## Obtain very rough approximation of optimal nu , which is 0.265 ########
#= n = 30000; T = 100; l = 100; nulo =0.2; nuhi = 0.3
nus = range(nulo, nuhi, l); Smeans=Array{Float64}(undef, l); min = 10^7; minid = 0
for i in 1:l
    _, Scanned, _ = sa.get_scanned_elements(n, T, nus[i])
    Smeans[i] = sum(Scanned)/n
    if ( Smeans[i] < min)
        global min = Smeans[i]; 
        global minid = i; 
    end
end
p = sa.plot(nus, Smeans, label="", xticks=range(nulo, nuhi, l/10)); display(p)
println("Minimal proportion of scanned elements $min found with ν = $(nus[minid])")
 =#
######## Check sesquickselct! correctness ad devault nu = 0.2843 ########
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