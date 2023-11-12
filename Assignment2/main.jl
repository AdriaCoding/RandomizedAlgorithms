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
n = 300; T = 1000; l = 100
nus = range(0.25, 0.27, l); Smeans=Array{Float64}(undef, l); min = 10^7; minid = 0
for i in 1:l
    _, Scanned, _ = sa.get_scanned_elements(n, T, nus[i])
    Smeans[i] = sum(Scanned)/n
    if ( Smeans[i] < min)
        global min = Smeans[i]; 
        global minid = i; 
    end
end
p = sa.plot(nus, Smeans, label=""); display(p)
println("Minimal proportion of scanned elements $min found with ν = $(nus[minid])")

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