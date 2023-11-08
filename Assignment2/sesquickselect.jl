const nu = 0.25;
## cop of base. make it YBB
function adaptative_partition!(v::AbstractVector, α, lo::Integer, hi::Integer, o::Ordering)
    # Pivots are the last and first elements of v. Assume this is random
    if lt(o, v[lo], v[hi])
        P, Q = v[lo], v[hi]
    else
        P, Q = v[hi], v[lo]
        v[hi], v[lo] = v[lo], v[hi]
    end
    i, j = lo, hi
    iter = 0
    # dual pivot partition (YBB)
    if (nu ≤ α && α ≤ 1 -nu) 
        k = i
        println("Pivots are ", P , " and ", Q , ": i=", i ," j=", j)

        @inbounds while true
            i += 1; j -= 1; k += 1
            if lt(o, v[k], P)
                v[k], v[i] = v[i], v[k]; i+=1
            elseif !lt(o, v[k], Q)
                while gt(o, v[j], Q) && k < j
                    j -=1
                end
                v[k], v[j] = v[j], v[k]; j-=1
                if lt(o, v[k], P) 
                    v[k], v[i] = v[i], v[k]; i+=1
                end
                
            end
            i >= j && break
        end
    # adaptative single pivot partition
    else 
        if (α < nu) pivot = P;  j+=1; pivot_index = lo;
        else pivot = Q; i-=1; pivot_index = hi; end;
        println("Pivot is ", pivot, ": i=", i ," j=", j)

        @inbounds while true
            while lt(o, v[i+=1], pivot); end
            while lt(o, pivot, v[j-=1]); end
            println("ITERATION ", iter, ": i=", i ," j=", j)
            i >= j && break
            println(v)
            v[i], v[j] = v[j], v[i]
            println(v)
            println("ITERATION ", iter+= 1, ": i=", i ," j=", j)
        end
        v[j], v[pivot_index] = pivot, v[j]
    end
    # v[j] == pivot
    # v[k] >= pivot for k > j
    # v[i] <= pivot for i < j
    return v
end
gt(o::Ordering, a, b) = !lt(o, a, b) && a != b