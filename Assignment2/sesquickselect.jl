const nu = 0.25;
## cop of base. make it YBB
function adaptative_partition!(v::AbstractVector, α, lo::Integer, hi::Integer, o::Ordering)
    # Pivots are the last and first elements of v. Assume this is random
    if (lt(o, v[lo], v[hi]))
        P, Q = v[lo], v[hi]
    else
        P, Q = v[hi], v[lo]
    end
    i, j = lo, hi

    if (nu ≤ α && α ≤ 1 -nu) # dual pivot partition
        k = i
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
    else # single pivot partition
        if (α < nu); pivot = P;
        elseif (α > 1-nu); pivot = Q; end;
        @inbounds while true
            i += 1; j -= 1
            while lt(o, v[i], pivot); i += 1; end;
            while lt(o, pivot, v[j]); j -= 1; end;
            i >= j && break
            v[i], v[j] = v[j], v[i]
        end
        v[j], v[lo] = pivot, v[j]
    end
    # v[j] == pivot
    # v[k] >= pivot for k > j
    # v[i] <= pivot for i < j
    return v
end
gt(o::Ordering, a, b) = !lt(o, a, b) && a != b