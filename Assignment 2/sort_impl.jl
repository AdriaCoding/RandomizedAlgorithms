const SMALL_ALGORITHM  = InsertionSort
const SMALL_THRESHOLD  = 20
# This is equivalent to the default Julia sort! algorithm for integers with ascending order. 
function default_quicksort!(v::AbstractVector, lo::Integer, hi::Integer)
    @inbounds while lo < hi # @inbounds macro used to avoid checking if inedexes are inbounds
        hi-lo <= SMALL_THRESHOLD && return sort!(v, lo, hi, SMALL_ALGORITHM, Base.Order.Forward)
        j = partition!(v, lo, hi, o)
        if j-lo < hi-j
            # recurse on the smaller chunk
            # this is necessary to preserve O(log(n))
            # stack space in the worst case (rather than O(n))
            lo < (j-1) && default_quicksort!(v, lo, j-1)
            lo = j+1
        else
            j+1 < hi && default_quicksort(v, j+1, hi)
            hi = j-1
        end
    end
    return v
end
function default_quicksort!(v::AbstractVector)
    inds = axes(v,1)
    default_quicksort!(v,first(inds),last(inds))
end

v = rand(1:100, 20)
println(v)
default_quicksort!(v)
println(v)