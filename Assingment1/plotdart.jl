import Pkg;
Pkg.add("Plots");
using Plots;


N= 1000;
global dart_count::UInt128 = 0;
π_estimate::Float64 = 0;
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



xs = rand(N)
ys = rand(N)

for darts in 1:N
    # generate random doubles x, y ∈ [0, 1)
    x, y = rand(Float64, 2) 
    cName = "orangered"
    if (x-.5)^2 + (y-.5)^2 <= .25
        cName = "springgreen"
        global dart_count += 1
    end
    plot!(p, (x,y), m=:x, color=cName)
    global π_estimate = 4*dart_count/darts
end
println("Estimated value of π with ", N ," darts: ", π_estimate)
println("Relative error: ", 100*abs(π_estimate-π)/π, "%")
plot!(p, title = string("N = ",N)*" darts thrown", xlims=(0,1), ylims=(0,1))
display(p)
savefig(p, "Assingment1/Diana_N="*string(N)*".svg")