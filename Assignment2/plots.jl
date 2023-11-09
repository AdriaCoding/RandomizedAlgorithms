function empirical_plot(I, S, n)
    X = map(i->i/n, I)
    println(I)
    println(X)
    plot(X, S)


end