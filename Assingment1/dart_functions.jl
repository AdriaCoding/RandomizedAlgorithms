function darts_pi(N)
    🎯 = 0
    for darts in 1:N
        # generate random doubles x, y ∈ [0, 1)
        x, y = rand(Float64, 2) 
        if (x-.5)^2 + (y-.5)^2 <= .25
            global 🎯 += 1
        end
    end
    return 4.0*🎯/N
end
function fast_darts(N)
    global 🎯 = 0
    points = rand(Float64, (N,2))
    for (x, y) in eachrow(points)
        if (x-.5)^2 + (y-.5)^2 <= .25
            global 🎯 += 1
        end
    end
    println(🎯)   
    return 4.0*🎯/N 
end

function faster_darts(N)
    global 🎯 = 0
    points = rand(Float64, (N,2))
    for (x, y) in eachrow(points)
        if (x)^2 + (y)^2 <= 1
            global 🎯 += 1
        end
    end
    println(🎯)   
    return 4.0*🎯/N 
end

function opt_darts(N)
    xs = rand(Float64, N)
    ys = rand(Float64, N)
    return 4.0 * count(xs.^2 .+ ys.^2 .< 1) / length(xs)
end
function online_darts(N)
    xs = rand(N)
    ys = rand(N)
    🎯 = count(xs.^2 .+ ys.^2 .<= 1)
    return 4.0 * 🎯 / N
end
function map_darts(N)
    xs = rand(N)
    ys = rand(N)
    🎯 = count(map((x,y)->x^2 + y^2 <= 1, xs, ys))
    return 4.0 * 🎯 / N
end

function piecewise_dart(n)
    xs = rand(n)
    ys = rand(n)
    return count(xs.^2 .+ ys.^2 .<= 1)
end
function master_dart(N)
    # Maximum size to call piecewise_dart(n)
    # 10^7 will consume approx 150MiB of memory in each call
    max_n = 10^6
    if N <= max_n
        return 4.0*piecewise_dart(N) / N
    end
    🎯s = max_n*ones(Int, N ÷ max_n + 1)
    🎯s[1] = N % max_n
    return mapreduce(n -> 4.0*piecewise_dart(n)/N, +, 🎯s)
end

time_darts(N) = @time darts_pi(N)
time_fast_darts(N) = @time fast_darts(N)
time_faster_darts(N) = @time faster_darts(N)
time_opt_darts(N) = @time opt_darts(N)
time_online_darts(N) = @time online_darts(N)
time_map_darts(N) = @time map_darts(N)