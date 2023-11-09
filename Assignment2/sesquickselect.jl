using Base.Order
nu = 0.33;
function single_partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    i, j, pivot = lo+1, hi, v[lo]
    @inbounds while true
        @inbounds while  lt(o, v[i], pivot) && i < hi; i+=1; end
        @inbounds while !lt(o, v[j], pivot) && j > lo ; j-=1; end
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
    i -= 1;
    while j < hi && v[j+=1] == Q; end
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
    if (n < 2)
        if hi == lo
            if v[m] == v[lo]; return v[m]; end
            error("sesquickselect FAILED as $(v[lo]) is not at rank $m")
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
        i, j = double_partition!(v, lo, hi, o)
    else
        randrank = rand(lo:hi)
        v[lo], v[randrank] = v[randrank], v[lo]
        i, j = single_partition!(v, lo, hi, o)

    end
    if m == i; return v[i]
    elseif m == j; return v[j]
    elseif m < i; return sesquickselect!(v, m, lo, i-1, o)
    elseif j < m; return sesquickselect!(v, m, j+1, hi, o)
    else return sesquickselect!(v, m, i+1, j-1, o)
    end
end
