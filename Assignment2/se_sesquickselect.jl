using Base.Order
nu = 0.33
## COUNT º SCANNED ELEMENTS IN VARIABLE 𝓢
function single_partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering, 𝓢)
    i, j, pivot = lo+1, hi, v[lo]
    𝓢+=1;
    @inbounds while true
        @inbounds while lt(o, v[i], pivot) && i < hi; i+=1; 𝓢+=1; end
        @inbounds while lt(o, pivot, v[j]) && j > lo ; j-=1; 𝓢+=1; end
        i >= j && break
        v[i], v[j] = v[j], v[i]

    end
    v[j], v[lo] = pivot, v[j];
    return j, j, 𝓢
end

function double_partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering, 𝓢)
    i, j = lo, hi
    # assume pivots are in order ( P <= Q )
    P, Q = v[lo], v[hi]
    i += 1; j -= 1; k = i; 𝓢+=2;
    @inbounds while k <= j
        if lt(o, v[k], P)
            v[k], v[i] = v[i], v[k]; i+=1; 𝓢+=1; #m mayb rm
        elseif !lt(o, v[k], Q)
            @inbounds while lt(o, Q, v[j]) && k < j
                j -=1; 𝓢+=1;
            end
            v[k], v[j] = v[j], v[k]; j-=1; 𝓢+=1;
            if lt(o, v[k], P)
                v[k], v[i] = v[i], v[k]; i+=1; 𝓢+=1; # mayb rv
            end
        end
        k+=1; 𝓢+=1;
    end
    i -= 1; j+=1;
    v[lo], v[i], v[j], v[hi] = v[i], P, Q, v[j]          
    return i, j, 𝓢
end

function two_distinct_rng(n::Integer, lo::Integer)
    ind = rand(0:(n * (n - 1) - 1))
    a, b = divrem(ind, n)
    a += (a >= b)
    return lo + a, lo + b
end

function sesquickselect!(v::AbstractVector, m, 𝓢)
    inds = axes(v,1)
    if(m < first(inds) || m > last(inds))
        return error("Desired rank is outside of vector range.")
    end
    sesquickselect!(v, m, first(inds), last(inds), Base.Order.Forward, 𝓢+2)
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
    if (nu <= α && α <= nu - 1)
        i, j = two_distinct_rng(n, lo)
        if lt(o, v[i], v[j]) 
            v[lo], v[i], v[j], v[hi] = v[i], v[lo], v[hi], v[j]
        else
            v[lo], v[j], v[i], v[hi] = v[j], v[lo], v[hi], v[i]
        end
        i, j, 𝓢 = double_partition!(v, lo, hi, o, 𝓢+2)
    else
        randrank = rand(lo:hi)
        v[lo], v[randrank] = v[randrank], v[lo]
        i, j, 𝓢 = single_partition!(v, lo, hi, o, 𝓢+1)

    end
    if m == i; return  𝓢
    elseif m == j; return  𝓢
    elseif m < i; return sesquickselect!(v, m, lo, i-1, o, 𝓢+1)
    elseif j < m; return sesquickselect!(v, m, j+1, hi, o, 𝓢+1)
    else return sesquickselect!(v, m, i+1, j-1, o, 𝓢+2)
    end
end

function get_scanned_elements(n::Integer, T::Integer)
    sorted = 1:n
    S = []; I=[]; itrtr = 0
    for i in range(0, step=max(1, trunc(Int, n/300)), stop=n)
        S_i = 0.0
        if(i == 0); i +=1; end
        for r in 1:T
            perm = shuffle(sorted)
            v = perm
            S_ir = sa.sesquickselect!(v, i, 0) 
            S_i += S_ir / T
        end
        S_i = round(S_i/n, digits=2)

        append!(I, i)
        append!(S, S_i)
    end
    return S, I
end
