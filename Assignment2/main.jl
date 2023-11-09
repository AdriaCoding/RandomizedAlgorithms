module SelectionAlgs
# Only once, load all the potentilly necessary libraries

#= import Pkg;
Pkg.add("BenchmarkTools"); #used to test out performance
Pkg.add("Plots");
Pkg.add("LaTeXStrings"); #used for cooler plots
Pkg.add("Random"); #used for shuffle method
 =#
using BenchmarkTools, Plots, LaTeXStrings, Base.Order, Random;

# Include all the functions in the project
include("sort_impl.jl")
include("sesquickselect.jl")
include("se_sesquickselect.jl")

export default_quicksort!, adaptative_partition!, 
get_scanned_elements, gSE;
end

import .SelectionAlgs as sa;

#= function get_scanned_elements(n, T)
    sorted = 1:n
    S = []
    for i in range(0, step=max(1, trunc(Int, n/300)), stop=n)
        S_i = 0.0
        for r in 1:T
            perm = shuffle(sorted)
            if(i == 0); i +=1; end
            v = perm
            S_ir = sa.sesquickselect!(v, i, 0) 
            S_i += S_ir / T
        end
        S_i = round(S_i/n, digits=2)
        append!(S, S_i)
    end
    return S
end =#
gSE() = get_scanned_elements(30000, 1000)
println(gSE())
#DEBUG ONLY
#= 
error = 0; n=3; T = 500
sorted = 1:n
for r in 1:T
    perm = shuffle(sorted)
    for i in range(0, step=max(1, trunc(Int, n/300)), stop=n)
        if(i == 0); i +=1; end
        v = perm
        element = sa.sesquickselect!(v, i)
        if sorted[i] != element; global error += 1
            println("$r: ", v, "\n====================\n");
        end
    end
end
if (error > 0) println("\n ================================================================ \nErrors commited: ", error); end =#