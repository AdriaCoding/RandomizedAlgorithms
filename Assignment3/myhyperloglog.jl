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
Base.sizeof(::Type{MyHyperLogLog{P}}) where {P} = 1 << P
Base.sizeof(x::MyHyperLogLog{P}) where {P} = sizeof(typeof(x))
MyHyperLogLog() = MyHyperLogLog{14}() # Default value

Base.isempty(x::MyHyperLogLog) = all(i == 0x00 for i in x.counts)

getbin(hll::MyHyperLogLog{P}, x::UInt) where P = x >>> (8 * sizeof(UInt) - P) + 1

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
    !isempty(x) || return 0
    harmonic_mean = sizeof(x) / sum(1 / 1 << i for i in x.counts)
    return round(Int,  α(x) * sizeof(x) * harmonic_mean)
end
#= 
a = MyHyperLogLog{10}()
push!(a, 4)
N = 10000000
push!(a, [randn() for i in 1:N]...)
println("N=$N vs estimation=$(length(a)).   Error relativo: $(100*abs(length(a)-N)/N) %")

 =#