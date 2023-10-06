using Pkg

N::UInt128 = 100
darts-thrown::UInt128 = 0
🎯::UInt128 = 0

while darts-thrown <= N
    # generate random doubles x, y ∈ [0, 1)
    x, y = rand(Float64, 2) 
    if x^2 + y^2 < 1
        

