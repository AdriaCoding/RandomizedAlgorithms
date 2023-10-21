# Generates random numbers iteritavely
function naive_darts(N)
    global 🎯 = 0
    for darts in 1:N
        # generate random doubles x, y ∈ [0, 1)
        x, y = rand(Float64, 2) 
        if (x-.5)^2 + (y-.5)^2 <= .25
            🎯 += 1
        end
    end
    return 4.0*🎯/N
end
# Works on an array of random numbers
function fast_darts(n, N = n)
    # Let the compiler do the typesetting.
    xs = rand(n)
    ys = rand(n)
    # . before an operator signifies element-wise operations.
    return 4.0/N * count((xs .- .5).^2 .+ (ys .- .5).^2 .<= .25)
end

# fast and naive darts mix. 
function master_darts(N, max_n = 10^6)
    # if N ≤ max_n , master_dart ≡ fast_darts
    global π_darts = fast_darts(N % max_n, N)
    for i in 1:(N ÷ max_n)
        global π_darts += fast_darts(max_n, N)
    end
    return π_darts
end