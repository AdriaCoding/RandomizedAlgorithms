# Generates random numbers iteritavely
function naive_darts(N)
    🎯 = 0
    for _ in 1:N
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
    return 4.0 / N * sum((xs .- .5).^2 .+ (ys .- .5).^2 .<= .25)
    
end

# fast and naive darts mix. 
function master_darts(N, max_n = 10^6)
    # if N ≤ max_n , master_dart ≡ fast_darts
    π_darts = fast_darts(N % max_n, N)
    for i in 1:(N ÷ max_n)
        π_darts += fast_darts(max_n, N)
    end
    return π_darts
end


function mycount(x,y)
    n = 0
    for i in eachindex(x,y)
        n +=  (x[i]-.5)^2 + (y[i]-.5)^2 <= .25
    end
    return n
end

function naive_count(N)
    n = 0
    for _ in 1:N
        x, y = rand(2)
        n +=  (x-.5)^2 + (y-.5)^2 <= .25
    end
    return n
end

function compare_impl(N=2^20)
    x = rand(N);
    y = rand(N);
    println("Time for method 1")
    @btime sum(($x .- .5).^2 .+ ($y.- .5).^2 .<= .25);
    println("Time for method 2")  
    @btime sum(p-> (p[1]-.5)^2 + (p[2]-.5)^2 <= .25, zip($x, $y));
    #@btime count(p-> (p[1]-.5)^2 + (p[2]-.5)^2 <= .25, zip($x, $y))
    println("Time for method 3")
    @btime mycount($x,$y);
    println("Time for method 4")
    @btime naive_count($N);
    println("Time for method 5")
    @btime sum(i-> ($x[i]-.5)^2 + ($y[i]-.5)^2 <= .25, eachindex($x))
    println("Time for RNG")
    @btime rand();
    println("Time for RNG vector")
    @btime rand($N);
    println("Time for RNG matrix")
    @btime rand($N,2);
    return
end

function fast_pi(N=2^20)
    x = rand(N);
    y = rand(N);
    return 4/N * mycount(x,y);
end
