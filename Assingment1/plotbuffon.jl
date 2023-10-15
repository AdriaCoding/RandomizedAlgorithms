import Pkg;
Pkg.add("Plots");
Pkg.add("LaTeXStrings");
using LaTeXStrings;
using Plots;

N= 100;
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


