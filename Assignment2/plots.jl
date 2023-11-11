include("theoretical.jl")

function empirical_plot(I, S, n, nu)
    X = map(i->i/n, I)
    p = plot(X, S, label="")

    x = range(0, 1,length=100)
    plot!(x, f.(x,nu), label="ν = $(nu)")
    return p
end
function variance_plot(I, V, n)
    return histogram(sqrt.(V)/n)
end

function compute_and_plot(n, T, nus)
    nplots = length(nus)
    ps = []
    x = range(0, 1,length=100)
    colors=cgrad(:darktest, nplots, categorical=true)
    for j in 1:nplots
        I, S, _ = get_scanned_elements(n, T, nus[j]);
        X = map(i->i/n, I)
        p = plot(X, S, label="", color=colors[j])
        p = plot!(x, f.(x,nus[j]), title="ν = $(nus[j])", label="", color=:black)
        #ps[j] = p
        push!(ps, p)
    end
    subplot_figure = plot(ps...)
    display(subplot_figure)
end    




