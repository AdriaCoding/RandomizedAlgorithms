# From Flajolet, Philippe; Fusy, Éric; Gandouet, Olivier; Meunier, Frédéric (2007)
# DOI: 10.1.1.76.4286

struct MyHyperLogLog{P}
    counts::Vector{UInt8}

    function MyHyperLogLog{P}() where {P}
        isa(P, Integer) || throw(ArgumentError("P must be integer"))
        (P < 4 || P > 18) && throw(ArgumentError("P must be between 4 and 18"))
        return new(zeros(UInt8, sizeof(MyHyperLogLog{P})))
    end
end

MyHyperLogLog() = MyHyperLogLog{14}() # Default value

Base.isempty(x::MyHyperLogLog) = all(i == 0x00 for i in x.counts)

# An UInt-sized hash is split, the first P bits is the bin index, the other bits the observation
getbin(hll::MyHyperLogLog{P}, x::UInt) where P = x >>> (8 * sizeof(UInt) - P) + 1

# Get number of trailing zeros + 1. We use the mask to prevent number of zeros
# from being overestimated due to any zeros in the bin part of the UInt
function getzeros(hll::MyHyperLogLog{P}, x::UInt) where {P}
    or_mask = ((UInt(1) << P) - 1) << (8 * sizeof(UInt) - P) #0x111111000000000000 with P ones at the left
    return trailing_zeros(x | or_mask) + 1
end

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
function α(x::MyHyperLogLog{P}) where {P} 
    if P == 4
        return 0.673
    elseif P == 5
        return 0.697
    elseif P == 6
        return 0.709
    else
        return 0.7213 / (1 + 1.079 / sizeof(x))
    end
end

function Base.length(x::MyHyperLogLog{P}) where {P}
    # Harmonic mean estimates cardinality per bin. There are 2^P = m bins
    harmonic_mean = sizeof(x) / sum(1 / 1 << i for i in x.counts)
    biased_estimate = α(x) * sizeof(x) * harmonic_mean
    return round(Int,  α(x) * sizeof(x) * harmonic_mean)
end

H = MyHyperLogLog{18}()
H.counts