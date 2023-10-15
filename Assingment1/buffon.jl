# Set l and t values here
l = 1/2
t = 1
function naive_buffon(N)
    global needle_crosses = 0
    for i in 1:N
        x = (t/2) * rand()
        θ = (π/2) * rand()
        if x ≤ (l/2) * sin(θ)
            global needle_crosses += 1
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
    C = count(xs .≤ (l/2) * sin.(θs))
    if C == 0
        return 0
    else
        return (2*l*N)/(t*C)
    end
end
function count_buffon(N)
    xs = (t/2) * rand(N)
    θs = (π/2) * rand(N)
    return count(xs .≤ (l/2) * sin.(θs))
end
# a mix of fast and naive methods. 
function master_buffon(N, max_n = 10^6)
    # if N ≤ max_n , master_buffon ≡ fast_buffon
    global C_global = count_buffon(N % max_n)
    for i in 1:(N ÷ max_n)
        println(count_buffon(max_n))
        global C_global += count_buffon(max_n)
    end
    if C_global == 0
        return 0
    else
        return (2*l*N)/(t*C_global)
    end
end

function ϵ(p)
    return 
end

using Plots
function plot_err_buffon()
    N = 10^3
    ϵ = zeros(N)
    p = zeros(N)
    for i in 1:N
        p[i] = master_buffon(i)
        ϵ[i] = abs(pi - p[i])/pi 
    end
    p_abs = plot(1:N, p)
    p_rel = plot(1:N, ϵ,
        xscale = :log10,
        yscale = :log10,
        xlims = (0, N)
    )
    display(p)
    
end