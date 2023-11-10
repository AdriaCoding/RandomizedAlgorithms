include("theoretical.jl")

function empirical_plot(I, S, n)
    X = map(i->i/n, I)
    plot(X, S)
    x = range(0, 1,length=100)

    plot!(x, f.(x,0.33), label="ν = $(0.33)")
end
