import Pkg
Pkg.add("Plots")

N = 100000000;
🎯 = 0; π = 0

for darts in 1:N
    # generate random doubles x, y ∈ [0, 1)
    x, y = rand(Float64, 2) 
    if x^2 + y^2 <= 1
        global 🎯 += 1
    end
    darts += 1
    global π = 4*🎯/darts
end
println("Estimated value of π: ", π)
