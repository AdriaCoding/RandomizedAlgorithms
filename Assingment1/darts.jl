# Generates random numbers iteritavely
function naive_darts(N)
    global 🎯 = 0
    for darts in 1:N
        # generate random doubles x, y ∈ [0, 1)
        x, y = rand(Float64, 2) 
        if (x-.5)^2 + (y-.5)^2 <= .25
            global 🎯 += 1
        end
    end
    return 4.0*🎯/N
end
# Works on an array of random numbers
function fast_darts(n, N = n)
    # Let the compiler do the typesetting.
    xs = rand(n)
    ys = rand(n)
    # .{operator} signifies element-wise operations.
    🎯 = count((xs .- .5).^2 .+ (ys .- .5).^2 .<= .25)
    return 4.0 * 🎯 / N
end
# Used for calling fast_darts in parallel
function master_dart(N, max_n = 10^6)
    if N ≤ max_n
        return fast_darts(N)
    end
    🎯s = max_n*ones(Int, N ÷ max_n + 1)
    🎯s[1] = N % max_n
    mapa = n -> fast_darts(n, N)
    return mapreduce(mapa, +, 🎯s)
end

function teste_dart(N, max_n = 10^6)
    if N ≤ max_n
        return fast_darts(N)
    end
    global π_approx = fast_darts(N % max_n, N)
    for i in 1:(N ÷ max_n)
        global π_approx += fast_darts(max_n, N)
    end
    return π_approx
end