include("theoretical.jl")

function empirical_plot(I, S, n, nu)
    X = map(i->i/n, I)
    p = plot(X, S, label="")

    x = range(0, 1,length=100)
    plot!(x, f.(x,nu), label="ν = $(nu)")
    return p
end

function compute_and_plot(n, T, nus)
    nplots = length(nus)
    ps = []
    qs = []
    x = range(0, 1,length=100)
    colors=cgrad(:darktest, nplots, categorical=true)
    for j in 1:nplots
        I, S, V = get_scanned_elements(n, T, nus[j]);
        X = map(i->i/n, I)
        p = plot(X, S, label="", color=colors[j], ylims=(1.5, 3.25))
        p = plot!(x, f.(x,nus[j]), title="ν = $(nus[j])", label="", color=:black)
        #ps[j] = p
        q = bar(X, sqrt.(V)/n,  title="ν = $(nus[j])", label="",
            fillcolor=colors[j], linecolor=colors[j])
        push!(qs, q)
        push!(ps, p)
    end
    subplot_figure = plot(ps...)
    variance_figure = plot(qs...)
    display(subplot_figure); display(variance_figure)
    savefig(subplot_figure,  "Assignment2/plots/exp-T="*string(T)*".svg")
    savefig(variance_figure, "Assignment2/plots/var-T="*string(T)*".svg")
end    




