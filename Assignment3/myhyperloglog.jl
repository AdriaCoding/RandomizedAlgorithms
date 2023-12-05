# From Flajolet, Philippe; Fusy, Éric; Gandouet, Olivier; Meunier, Frédéric (2007)
# DOI: 10.1.1.76.4286

"""
    MyHyperLogLog{P}()

Construct a MyHyperLogLog cardinality counter. Hashable values can be added to the
counter, and an approximate count of distinct elements (cardinality) retrieved.
The counter has an error of < 2.5% w. 99% probability and median error of 0.5%,
but is only accurate for 2^10 < cardinality < 2^62.

An MyHyperLogLog{P} consumes 2^P bytes of memory. I recommend P = 14 (using 16 KiB).

# Examples
```
julia> hll = MyHyperLogLog{14}();

julia> for i in 1:1<<28 push!(hll, i) end

julia> length(hll)
271035100

julia> empty!(hll);
```
"""
struct MyHyperLogLog{P}
    counts::Vector{UInt8}

    function MyHyperLogLog{P}() where {P}
        isa(P, Integer) || throw(ArgumentError("P must be integer"))
        (P < 4 || P > 18) && throw(ArgumentError("P must be between 4 and 18"))
        return new(zeros(UInt8, sizeof(MyHyperLogLog{P})))
    end
end

MyHyperLogLog() = MyHyperLogLog{14}() # Default value

"""
    union!(dest::MyHyperLogLog{P}, src::MyHyperLogLog{P})

Overwrite `dest` with the same result as `union(dest, src)`, returning `dest`.

# Examples
```
julia> # length(c) ≥ length(b) is not guaranteed, but overwhelmingly likely
julia> c = union!(a, b); c === a && length(c) ≥ length(b)
true
```
"""
function Base.union!(dest::MyHyperLogLog{P}, src::MyHyperLogLog{P}) where {P}
    for i in 1:sizeof(dest)
        @inbounds dest.counts[i] = max(dest.counts[i], src.counts[i])
    end
    return dest
end

"""
    union(x::MyHyperLogLog{P}, y::MyHyperLogLog{P})

Create a new HLL identical to an HLL which has seen the union of the elements
`x` and `y` has seen.

# Examples
```
julia> # That c is longer than a or b is not guaranteed, but overwhelmingly likely
julia> c = union(a, b); length(c) ≥ length(a) && length(c) ≥ length(b)
true
```
"""
Base.union(x::MyHyperLogLog{P}, y::MyHyperLogLog{P}) where {P} = union!(copy(x), y)

function Base.copy!(dest::MyHyperLogLog{P}, src::MyHyperLogLog{P}) where {P}
    unsafe_copyto!(dest.counts, 1, src.counts, 1, UInt(sizeof(dest)))
    return dest
end


"""
    empty!(x::MyHyperLogLog)

Reset the HLL to its beginning state (i.e. "deleting" all elements from the HLL),
returning it.

# Examples
```
julia> empty!(a); length(a) # should return approximately 0
1
```
"""
Base.empty!(x::MyHyperLogLog) = (fill!(x.counts, 0x00); x)

"""
    isempty(x::MyHyperLogLog)

Return `true` if the HLL has not seen any elements, `false` otherwise.
This is guaranteed to be correct, and so can be `true` even when length(x) > 0.

# Examples
```
julia> a = MyHyperLogLog{14}(); (length(a), isempty(a))
(1, true)

>julia push!(a, 1); (length(a), isempty(a))
(1, false)
```
"""
Base.isempty(x::MyHyperLogLog) = all(i == 0x00 for i in x.counts)

# An UInt-sized hash is split, the first P bits is the bin index, the other bits the observation
getbin(hll::MyHyperLogLog{P}, x::UInt) where {P} = x >>> (8 * sizeof(UInt) - P) + 1

# Get number of trailing zeros + 1. We use the mask to prevent number of zeros
# from being overestimated due to any zeros in the bin part of the UInt
function getzeros(hll::MyHyperLogLog{P}, x::UInt) where {P}
    or_mask = ((UInt(1) << P) - 1) << (8 * sizeof(UInt) - P)
    return trailing_zeros(x | or_mask) + 1
end

"""
    push!(hll::MyHyperLogLog, items...)

Add each item to the HLL. This has no effect if the HLL has seen the items before.

# Examples
```
julia> a = MyHyperLogLog{14}(); push!(a, 1,2,3,4,5,6,7,8,9); length(a)
9
```
"""
function Base.push!(hll::MyHyperLogLog, x)
    h = hash(x)
    bin = getbin(hll, h)
    @inbounds hll.counts[bin] = max(hll.counts[bin], getzeros(hll, h))
    return hll
end

function Base.push!(hll::MyHyperLogLog, values...)
    for value in values
        push!(hll, value)
    end
    return hll
end

# This corrects for systematic bias in the harmonic mean, see original paper.
α(x::MyHyperLogLog{P}) where {P} =
    if P == 4
        return 0.673
    elseif P == 5
        return 0.697
    elseif P == 6
        return 0.709
    else
        return 0.7213 / (1 + 1.079 / sizeof(x))
    end

"""
    length(hll::MyHyperLogLog{Precision})

Estimate the number of distinct elements the HLL has seen. The error depends on
the Precision parameter. This has low absolute rror when the estimate is small,
and low relative error when the estimate is high.

# Examples
```
julia> a = MyHyperLogLog{14}(); push!(a, 1,2,3,4,5,6,7,8); length(a)
9
```
"""
function Base.length(x::MyHyperLogLog{P}) where {P}
    # Harmonic mean estimates cardinality per bin. There are 2^P bins
    harmonic_mean = sizeof(x) / sum(1 / 1 << i for i in x.counts)
    biased_estimate = α(x) * sizeof(x) * harmonic_mean
    return round(Int, biased_estimate - bias(x, biased_estimate))
end