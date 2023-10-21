include("../Assingment1/darts.jl")
include("../Assingment1/buffon.jl")

#using Pkg
#Pkg.add("DataStructures") # otherwise count() can bug
using BenchmarkTools #used to test out performance
using Plots
pyplot()
using LaTeXStrings

function plot_err(e, pi_function)
    N = 10^e
    rng = collect(0:10^(e-3):N)    
    p = pi_function.(rng)
    p_abs = plot(rng, p,
        legend = false,
        xlims = [0, 10^e],
        ylabel = L"Approximation",
        ylims = [3.1, 3.2],
        xlabel = L"$N$"
    )
    xaxis!(p_abs, 
        minorgrid = true,
    )

    plot!(p_abs, [0, N], [pi, pi],
        linecolor = :red,
        linestyle = :dash
    )

    rerr = abs.(p .-pi)/pi 
    p_rel = plot(rng, rerr,
        yscale = :log10,
        ylabel = "Relative Error",
        legend = false,
        xlabel = L"$N$",
    )
    display(p_abs)
    display(p_rel)
end
@time plot_err(6, master_buffon)