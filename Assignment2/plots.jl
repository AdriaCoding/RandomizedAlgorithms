include("theoretical.jl")

function empirical_plot(I, S, n, nu)
    X = map(i->i/n, I)
    p = plot(X, S, label="")

    x = range(0, 1,length=100)
    plot!(x, f.(x,nu), label="ν = $(nu)")
    display(p)
end
function variance_plot(I, V, n)
    return histogram(sqrt.(V)/n)
end
