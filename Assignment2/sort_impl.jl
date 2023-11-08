
# @inbounds macro avoids checking if array indices are in range.
# default selectpivot method by julia
@inline function selectpivot!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    @inbounds begin
        mi = midpoint(lo, hi)

        # sort v[mi] <= v[lo] <= v[hi] such that the pivot is immediately in place
        if lt(o, v[lo], v[mi])
            v[mi], v[lo] = v[lo], v[mi]
        end

        if lt(o, v[hi], v[lo])
            if lt(o, v[hi], v[mi])
                v[hi], v[lo], v[mi] = v[lo], v[mi], v[hi]
            else
                v[hi], v[lo] = v[lo], v[hi]
            end
        end

        # return the pivot
        return v[lo]
    end
end

# default partition method arround one pivot
function partition!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    pivot = selectpivot!(v, lo, hi, o)
    # pivot == v[lo], v[hi] > pivot
    i, j = lo, hi
    @inbounds while true
        i += 1; j -= 1
        while lt(o, v[i], pivot); i += 1; end;
        while lt(o, pivot, v[j]); j -= 1; end;
        i >= j && break
        v[i], v[j] = v[j], v[i]
    end
    v[j], v[lo] = pivot, v[j]

    # v[j] == pivot
    # v[k] >= pivot for k > j
    # v[i] <= pivot for i < j
    return j
end

const SMALL_ALGORITHM  = InsertionSort
const SMALL_THRESHOLD  = 20
# This is equivalent to the default Julia sort! algorithm for integers with ascending order. 
function default_quicksort!(v::AbstractVector, lo::Integer, hi::Integer, o::Ordering)
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return sort!(v, lo, hi, SMALL_ALGORITHM, o)
        j = partition!(v, lo, hi, o)
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo < (j-1) && default_quicksort!(v, lo, j-1, o)
            lo = j+1
        else
            j+1 < hi && default_quicksort!(v, j+1, hi, o)
            hi = j-1
        end
    end
    return v
end

function default_quicksort!(v::AbstractVector)
    inds = axes(v,1)
    default_quicksort!(v,first(inds),last(inds), Base.Order.Forward)
end

###############################

#= 
    In Julia, quickselect is dispatched within sort! using the keyword
    Algorithm = PartialQuickSort, which is a structure containing the 
    desired selection indexes `k` as a vector. Here is a copy of the 
    Base implementation, but for selecting a single element k.
=#

function quickselect!(v::AbstractVector, lo::Integer, hi::Integer, k::Integer, o::Ordering)
    @inbounds while lo < hi
        hi-lo <= SMALL_THRESHOLD && return sort!(v, lo, hi, SMALL_ALGORITHM, o)
        j = partition!(v, lo, hi, o) #pivot index

        if j <= first(k)
        lo = j+1
        elseif j >= last(k)
        hi = j-1
        else
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            if j-lo < hi-j
                lo < (j-1) && quickselect!(v, lo, j-1, k, o)
                lo = j+1
            else
                hi > (j+1) && quickselect!(v, j+1, hi, k, o)
                hi = j-1
            end
        end
    end
    return v[k]
end
function quickselect!(v::AbstractVector, k::Integer)
    inds = axes(v,1)
    quickselect!(v,first(inds),last(inds), k , Base.Order.Forward)
    return v[k]
end
v = rand(1:100, 20)
println(v)
println(quickselect!(v, 10))
println(v)
default_quicksort!(v)
println(v)