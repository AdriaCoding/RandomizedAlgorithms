#import Pkg;
#Pkg.add("Plots");
using Plots;

N= 100000;
🎯::UInt128 = 0;
π_estimate::Float64 = 0;
p = plot(t->.5+.5*cos(t), t->.5+.5*sin(t), 0, 2*π, fill=true, opacity=.8);
plot!(p, Shape([0,0,1,1],[0,1,1,0]), aspect_ratio = 1, opacity=.4, legend=false);
for darts in 1:N
    # generate random doubles x, y ∈ [0, 1)
    x, y = rand(Float64, 2) 
    cName = "orangered"
    if (x-.5)^2 + (y-.5)^2 <= .25
        cName = "springgreen"
        global 🎯 += 1
    end
    plot!(p, (x,y), m=:x, color=cName)
    global π_estimate = 4*🎯/darts
end
println("Estimated value of π with ", N ," darts: ", π_estimate)
println("Relative error: ", 100*abs(π_estimate-π)/π, "%")
display(p)
