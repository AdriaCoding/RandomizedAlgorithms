l = 1/2
t = 1
function naive_buffon(N)
    global 🪡 = 0
    for i in 1:N
        x = (t/2) * rand()
        θ = (π/2) * rand()
        if x ≤ (l/2) * sin(θ)
            global 🪡 += 1
        end
    end
    return (2*l*N)/(t*🪡)
end

function fast_buffon(N)
    xs = (t/2) * rand(N)
    θs = (π/2) * rand(N)
    C = count(xs .≤ (l/2) * sin.(θs))
    return (2*l*N)/(t*C)
end
function piecewise_buffon(N)
    xs = (t/2) * rand(N)
    θs = (π/2) * rand(N)
    return count(xs .≤ (l/2) * sin.(θs))
end
function master_buffon(N)
    # Maximum size to call fast_buffon(n)
    max_n = 10^5
    if N <= max_n
        return fast_buffon(N)
    end
    # We plan on calling fast_buffon over a whole array
    Cs = max_n*ones(Int, N ÷ max_n + 1)
    Cs[1] = N % max_n
    # Compute the mapping and add up all the values into C
    C = mapreduce(n -> piecewise_buffon(n), +, Cs)
    return (2*l*N)/(t*C)
end