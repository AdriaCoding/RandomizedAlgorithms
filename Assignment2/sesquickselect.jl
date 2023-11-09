using Base.Order
const nu = 0.33;
## cop of base. make it YBB
function adaptative_partition!(v::AbstractVector, α, lo::Integer, hi::Integer, o::Ordering)
    if lt(o, v[hi], v[lo])
        v[hi], v[lo] = v[lo], v[hi]
    end
    i, j = lo, hi
    # Pivots are the last and first elements of v. Assume this is random
    P, Q = v[lo], v[hi]
    # dual pivot partition (YBB)
    if (nu ≤ α && α ≤ 1 - nu) 
        i += 1; j -= 1; k = i;
        @inbounds while true
            if lt(o, v[k], P)
                v[k], v[i] = v[i], v[k]; i+=1
            elseif !lt(o, v[k], Q)
                @inbounds while k < j && lt(o, Q, v[j])
                    j -=1
                end
                v[k], v[j] = v[j], v[k]; j-=1
                if lt(o, v[k], P) 
                    v[k], v[i] = v[i], v[k]; i+=1
                end
            end
            k+=1; k > j && break
        end
        i-=1; j+=1
        v[lo], v[i], v[j], v[hi] = v[i], P, Q, v[j]
    # adaptative single pivot partition
    else 
        if (α < nu) pivot = P;  i+=1; pivot_index = lo;
        else pivot = Q; j-=1; pivot_index = hi; end;
        @inbounds while true
            while lt(o, v[i], pivot); i+=1; end
            while lt(o, pivot, v[j]); j-=1; end
            i >= j && break
            v[i], v[j] = v[j], v[i]
        end
        α < nu ? i = j : j = i
        v[j], v[pivot_index] = pivot, v[j]
    end
    return i, j
end
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
    #println(v, i, j, k)
    @inbounds while k <= j
        if lt(o, v[k], P)
            #println(v, i, j, k)
            v[k], v[i] = v[i], v[k]; i+=1
            #println(v, i, j, k)
        elseif !lt(o, v[k], Q)
            @inbounds while lt(o, Q, v[j]) && k < j
                j -=1
            end
            #println(v, i, j, k)
            v[k], v[j] = v[j], v[k]; j-=1
            #println(v, i, j, k)
            if lt(o, v[k], P)
                #println(v, i, j, k)
                v[k], v[i] = v[i], v[k]; i+=1
                #println(v, i, j, k)
            end
        end
        k+=1
    end
    i -= 1;
    while j < hi && v[j+=1] == Q; end
    #while lo < i && v[i] == P; i-=1; end
    v[lo], v[i], v[j], v[hi] = v[i], P, Q, v[j]          
    #println(v, i, j, k)
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
    if (n <= 3)
        sort!(v, lo, hi, InsertionSort, o)
        return v[m]
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
