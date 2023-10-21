function plot_everything()
    plot_dart();
    plot_err(7, master_darts);
    plot_buffon();
    plot_err(7, master_buffon);
end
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
    name = "Error_"
    if pi_function == master_buffon
        name = name * "Buffon_"
    end
    if pi_function == master_darts
        name = name * "Darts_"
    end
    name = name * "e="*string(e);
    display(p_abs)
    display(p_rel)
    savefig(p_abs, "Assingment1/plots/Absolute_"*name*".svg")
    savefig(p_rel, "Assingment1/plots/Relative_"*name*".svg")
end


function plot_buffon(N=100)
    t = .5
    l2 = .25
    x = (t/2)*rand(N)
    θ = (π/2)*rand(N)
    y_iv = .75;
    y = y_iv*rand(N)
    Ax = x - l2*sin.(θ)
    Ay = y - l2*cos.(θ)
    Bx = x + l2*sin.(θ)
    By = y + l2*cos.(θ)
    p = plot(Shape([0,0,.5,.5],[0,y_iv,y_iv,0]),
        fill="silver",
        linecolor = :black,
        xlims=(-.2,t + .2),
        ylims=(0, y_iv-.01),
        aspect_ratio = 1)
    p = plot!(p, [0,0], [0,y_iv],
        title = "N = "*string(N)*" needles thrown",
        linecolor = :black,
        legend = false,
        size = (350,350),
        margin = (1, :mm),
        yaxis=(ticks=false),
        xaxis=(draw_arrow=true),
        grid=false)
    p = plot!(p, [t/2,t/2], [0,y_iv], linecolor = :black, linestyle=:dash)
    xticks!(p, [0, .25, .5], [L"0",L"\frac{t}{2}", L"t"])
    global count = 0
    for i in 1:N
        cName = "orangered"
        if (x[i] ≤ l2*sin(θ[i]))
            cName = "springgreen"
            global count += 1
        end
        plot!(p, [Ax[i],Bx[i]],[Ay[i], By[i]], linecolor = cName)
    end
    display(p)
    savefig(p, "Assingment1/plots/Buffon_N="*string(N)*".svg")
    return (2*(2*l2)*N)/(t*count)
end

function plot_dart(N = 1000)
    p = plot(t->.5+.5*cos(t), t->.5+.5*sin(t), 0, 2*π,
        fill=true,
        opacity=.8
        );
    plot!(p,
        Shape([0,0,1,1],[0,1,1,0]),
        aspect_ratio = 1,
        opacity=.4,
        size = (350, 350),
        legend=false
        );
    xticks!(p, [0, .5, 1], [L"0", L"\frac{1}{2}",L"1"])
    p = plot!(p, [1/2,1/2], [0,1], linecolor = :black, linestyle=:dash)
    yticks!(p, [.5, 1], [L"\frac{1}{2}",L"1"])
    p = plot!(p, [0,1], [1/2,1/2], linecolor = :black, linestyle=:dash)
    for darts in 1:N
        # generate random doubles x, y ∈ [0, 1)
        x, y = rand(Float64, 2) 
        cName = "orangered"
        if (x-.5)^2 + (y-.5)^2 <= .25
            cName = "springgreen"
        end
        plot!(p, (x,y), m=:x, color=cName)
    end
    plot!(p, title = string("N = ",N)*" darts thrown", xlims=(0,1), ylims=(0,1))
    display(p)
    savefig(p, "Assingment1/Diana_N="*string(N)*".svg")
end

