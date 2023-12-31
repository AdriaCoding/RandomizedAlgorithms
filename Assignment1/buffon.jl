# Set l and t values here
const global l = 1/2
const global t = 1
function naive_buffon(N)
    needle_crosses = 0
    for _ in 1:N
        x = (t/2) * rand()
        θ = (π/2) * rand()
        if x ≤ (l/2) * sin(θ)
            needle_crosses += 1
        end
    end
    if needle_crosses == 0
        return 0
    else 
        return (2*l*N)/(t*needle_crosses)
    end
end

function fast_buffon(N)
    xs = (t/2) * rand(N)
    θs = (π/2) * rand(N)
    C = sum(xs .≤ (l/2) * sin.(θs))
    if C == 0
        return 0
    else
        return (2*l*N)/(t*C)
    end
end

# auxiliary function for master_buffon
function count_buffon(N)
    xs = (t/2) * rand(Float64, N)
    θs = (π/2) * rand(Float64, N)
    return sum(xs .≤ (l/2) * sin.(θs))
end

# a mix of fast and naive methods. 
function master_buffon(N, max_n = 10^6)
    # if N ≤ max_n , master_buffon ≡ fast_buffon
    C_global = count_buffon(N % max_n)
    for _ in 1:(N ÷ max_n)
        C_global += count_buffon(max_n)
    end
    if C_global == 0
        return 0
    else
        return (2*l*N)/(t*C_global)
    end
end