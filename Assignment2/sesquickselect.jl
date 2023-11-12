using Base.Order

# Auxiliary functions for sesquickselect
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
    # assume pivots are in order ( P < Q )
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
    # Some cool and fast implementation by performance hacker `GunnarFarneback`
    # https://discourse.julialang.org/t/draw-two-distinct-random-integers-from-1-n/72289/19
    ind = rand(0:(n * (n - 1) - 1))
    a, b = divrem(ind, n)
    a += (a >= b)
    return lo + a, lo + b
end

function select_two_pivots!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    i, j = two_distinct_rng(hi - lo + 1, lo)
    if lt(o, v[j], v[i]) i, j = j, i end    # ensure that i points to the smallest pivot
    v[lo], v[i] = v[i], v[lo]   # place pivot v[i] at the beggining
    if (j == lo) j = i end  # prevent dumbest source of error
    v[j], v[hi] = v[hi], v[j]   # place pivot v[j] at the end
end
#####################################
# Sesquickselect methods
# Use optimal value of nu by default
sesquickselect!(v::AbstractVector, m::Integer) = sesquickselect!(v::AbstractVector, m, 0.265)
function sesquickselect!(v::AbstractVector, m::Integer, nu)
    inds = axes(v,1)
    if(m < first(inds) || m > last(inds))
        return error("Desired rank is outside of vector range.")
    end
    sesquickselect!(v, m, first(inds), last(inds), nu, Base.Order.Forward)
end
function sesquickselect!(v::AbstractVector, m::Integer, lo::Integer, hi::Integer, nu, o::Ordering)
    n = hi - lo + 1
    if (n < 1) return error("sesquickselect FAILED as it was called with hi < lo: $hi < $lo"); end;
    if (n == 1) 
        if (m == lo) return v[m];
        else return error("sesquickselect FAILED as m=$m is out of bounds (lo=$lo, hi=$hi)")
        end
    end

    # Select two pivots and place them in the bounds -> lo, hi
    select_two_pivots!(v, lo, hi, o) # P = v[lo] < v[hi] = Q

    # Partition the array depending on α
    α = (m-lo) / n  # use relative ranks
    if ( nu <= α && α <= 1 - nu )
        i, j = double_partition!(v, lo, hi, o)
    else
        if (α > 1-nu) v[lo], v[hi] = v[hi], v[lo] end
        i, j = single_partition!(v, lo, hi, o)
    end
    
    # Recursive Step
    if m == i return v[i]
    elseif m == j return v[j]
    elseif m < i return sesquickselect!(v, m, lo, i-1, nu, o)
    elseif j < m return sesquickselect!(v, m, j+1, hi, nu, o)
    else return sesquickselect!(v, m, i+1, j-1, nu, o)
    end
end
#####################################################

# used to count number of scanned elements
function sesquickselect!(v::AbstractVector, m::Integer, nu, S::Integer)
    inds = axes(v,1)
    if(m < first(inds) || m > last(inds))
        return error("Desired rank is outside of vector range.")
    end
    sesquickselect!(v, m, first(inds), last(inds), nu, Base.Order.Forward, S)
end

function sesquickselect!(v::AbstractVector, m::Integer, lo::Integer, hi::Integer, nu, o::Ordering, S::Integer)
    n = hi - lo + 1

    if (n < 1) return error("sesquickselect FAILED as it was called with hi < lo: $hi < $lo"); end;
    if (n == 1) 
        if (m == lo) return S, v[m];
        else return error("sesquickselect FAILED as m=$m is out of bounds (lo=$lo, hi=$hi)")
        end
    end

    # Select two pivots and place them in the bounds -> lo, hi
    select_two_pivots!(v, lo, hi, o) # P = v[lo] < v[hi] = Q

    # Partition the array depending on α
    α = (m-lo) / n  # use relative ranks
    if ( nu <= α && α <= 1 - nu )
        i, j = double_partition!(v, lo, hi, o)
        S += (n - 2 + i - lo)
    else
        if (α > 1-nu) v[lo], v[hi] = v[hi], v[lo] end
        i, j = single_partition!(v, lo, hi, o)
        S += (n - 1)
    end

    # Recursive step
    if m == i; return  S, v[m]
    elseif m == j; return  S, v[m]
    elseif m < i; return sesquickselect!(v, m, lo, i-1, nu, o, S)
    elseif j < m; return sesquickselect!(v, m, j+1, hi, nu, o, S)
    else return sesquickselect!(v, m, i+1, j-1, nu, o, S)
    end
end

function get_scanned_elements(n::Integer, T::Integer, ν)
    sorted = 1:n; S = []; I=[]; V=[]
    perms =  map(r->shuffle(sorted), 1:T)
    for i in range(0, step=max(1, trunc(Int, n/300)), stop=n)
        S_i = 0.0; S_ir = zeros(AbstractFloat, T)
        if(i == 0) i +=1 end
        for r in 1:T
            vect = copy(perms[r])  
            S_ir[r], element = sesquickselect!(vect, i, ν, 0) 
            if element != i
                println("Error at permutation $(perms[r]) with m = $i. Returned element count $(S_ir[r])")
            end
        end
        mean = sum(S_ir) / T
        variance = sum((S_ir.-mean).^2) / (T-1)
        S_i = mean/n

        append!(I, i)
        append!(S, S_i)
        append!(V, variance)
    end
    return I, S, V
end
