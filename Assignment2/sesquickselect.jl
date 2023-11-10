using Base.Order
nu = 0.33;
function single_partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    i, j, pivot = lo+1, hi, v[lo]
    @inbounds while true
        @inbounds while lt(o, v[i], pivot) && i < hi; i+=1; end
        @inbounds while lt(o, pivot, v[j]) && j > lo ; j-=1; end
        i >= j && break
        v[i], v[j] = v[j], v[i]

    end
    v[j], v[lo] = pivot, v[j];
    return j, j
end

function double_partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    i, j = lo, hi
    # assume pivots are in order ( P <= Q )
    P, Q = v[lo], v[hi]
    i += 1; j -= 1; k = i;
    @inbounds while k <= j
        if lt(o, v[k], P)
            v[k], v[i] = v[i], v[k]; i+=1
        elseif !lt(o, v[k], Q)
            @inbounds while lt(o, Q, v[j]) && k < j
                j -=1
            end
            v[k], v[j] = v[j], v[k]; j-=1
            if lt(o, v[k], P)
                v[k], v[i] = v[i], v[k]; i+=1
            end
        end
        k+=1
    end
    i -= 1; j+=1;
    v[lo], v[i], v[j], v[hi] = v[i], P, Q, v[j]          
    return i, j
end

function two_distinct_rng(n::Integer, lo::Integer)
    ind = rand(0:(n * (n - 1) - 1))
    a, b = divrem(ind, n)
    a += (a >= b)
    return lo + a, lo + b
end

function sesquickselect!(v::AbstractVector, m)
    inds = axes(v,1)
    if(m < first(inds) || m > last(inds))
        return error("Desired rank is outside of vector range.")
    end
    sesquickselect!(v, m, first(inds), last(inds), Base.Order.Forward)
end
function sesquickselect!(v::AbstractVector, m::Integer, lo::Integer, hi::Integer, o::Ordering)
    n = hi - lo + 1
    if (n < 1) return error("sesquickselect FAILED as it was called with hi ≤ lo: $hi ≤ $lo"); end;
    if (n <= 2) # n=1,2
        if (lt(o, v[hi], v[lo])) v[lo], v[hi] = v[hi], v[lo]; end

        if (m == lo || m == hi) return v[m];
        else return error("sesquickselect FAILED as m=$m is out of bounds (lo=$lo, hi=$hi)")
        end
    end
    α = m / n
    if (true #= & (nu <= α) && α <= 1 - nu =#)
        i, j = two_distinct_rng(n, lo)
        println("ranks = $lo, $hi; pivots = ($i->$(v[i]), $j->$(v[j]))")
        println(v, "Before pivot positioning")

        ti, tlo, thi, tj = deepcopy(v[i]), deepcopy(v[lo]), deepcopy(v[hi]), deepcopy(v[j])
        if lt(o, v[i], v[j]) 
            println("v[$i] < v[$j]")
            v[lo], v[i], v[j], v[hi] = ti, tlo, thi, tj
        else
            println("v[$j] < v[$j]")
            v[lo], v[j], v[i], v[hi] = tj, tlo, thi, ti
        end
        println(v, "After pivot positioning")
        i, j = double_partition!(v, lo, hi, o)
        println(v, "($i, $j)")
    else
        randrank = rand(lo:hi)
        v[lo], v[randrank] = v[randrank], v[lo]
        i, j = single_partition!(v, lo, hi, o)

    end
    println("     ¿What should I call?        m=$m, i=$i, j=$j")
    if m == i; return v[i]
    elseif m == j; return v[j]
    elseif m < i; println("CALL 1: $lo, $(i-1)"); return sesquickselect!(v, m, lo, i-1, o)
    elseif j < m; println("CALL 2: $(j-1), $(hi)"); return sesquickselect!(v, m, j+1, hi, o)
    else println("CALL 3: $(i+1), $(j-1)"); return sesquickselect!(v, m, i+1, j-1, o)
    end
end
#####################################################

# used to count number of scanned elements
function sesquickselect!(v::AbstractVector, m, 𝓢)
    inds = axes(v,1)
    if(m < first(inds) || m > last(inds))
        return error("Desired rank is outside of vector range.")
    end
    sesquickselect!(v, m, first(inds), last(inds), Base.Order.Forward, 𝓢)
end

function sesquickselect!(v::AbstractVector, m::Integer, lo::Integer, hi::Integer, o::Ordering, 𝓢)
    # Assume lo and hi indices are already scanned.
    n = hi - lo + 1
    if (n < 2)
        if hi == lo
            if m == lo; return 𝓢; end
            error("sesquickselect FAILED as rank $m is outside bounds ($lo, $hi)")
        else
            error("sesquickselect FAILED as it was called with hi ≤ lo: $hi ≤ $lo")
        end
    end
    α = m / n
    if (nu <= α && α <= 1 - nu)
        i, j = two_distinct_rng(n, lo)
        if lt(o, v[i], v[j]) 
            v[lo], v[i], v[j], v[hi] = v[i], v[lo], v[hi], v[j]
        else
            v[lo], v[j], v[i], v[hi] = v[j], v[lo], v[hi], v[i]
        end
        i, j = double_partition!(v, lo, hi, o)
        𝓢 += (n-2+i-1)
    else
        randrank = rand(lo:hi)
        v[lo], v[randrank] = v[randrank], v[lo]
        i, j = single_partition!(v, lo, hi, o)
        𝓢 += (n-1)
    end
    if m == i; return  𝓢
    elseif m == j; return  𝓢
    elseif m < i; return sesquickselect!(v, m, lo, i-1, o, 𝓢)
    elseif j < m; return sesquickselect!(v, m, j+1, hi, o, 𝓢)
    else return sesquickselect!(v, m, i+1, j-1, o, 𝓢)
    end
end

function get_scanned_elements(n::Integer, T::Integer)
    println("get_scanned_elements function is getting called.")
    sorted = 1:n
    S = []; I=[]; itrtr = 0
    for i in range(0, step=max(1, trunc(Int, n/300)), stop=n)
        S_i = 0.0
        if(i == 0); i +=1; end
        for r in 1:T
            perm = shuffle(sorted)
            v = perm
            S_ir = sesquickselect!(v, i, 0) 
            S_i += S_ir / T
        end
        S_i = round(S_i/n, digits=2)

        append!(I, i)
        append!(S, S_i)
    end
    return I, S
end
