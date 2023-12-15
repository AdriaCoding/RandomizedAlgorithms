import DataStructures: SortedSet
using XXhash
struct xKMV{k}
    values::SortedSet{Float64}
    function xKMV{k}() where k
        isa(k, Integer) || throw(ArgumentError("k must be an integer"))
        return new(SortedSet{Float64}(Base.Order.Reverse))
    end
    function xKMV{k}(initial_values) where k
        kmv = xKMV{k}()
        for v in initial_values
            push!(kmv, v)
        end
        return kmv
    end
end

xKMV() = xKMV{3}()

Base.max(kmv::xKMV) = first(kmv.values)

function Base.push!(kmv::xKMV{k}, x) where {k}
    h = (xxh64(x)/(1<<63-1))/2
    if length(kmv.values) < k
        insert!(kmv.values, h)
    elseif h < max(kmv)
        insert!(kmv.values, h)
        pop!(kmv.values)
    end
    return kmv.values
end

function Base.push!(kmv::xKMV, v::AbstractArray)
    for item in v
        push!(kmv, item)
    end
    return kmv.values
end

function Base.push!(kmv::xKMV, entries...)
    for entry in entries
        push!(kmv, entry)
    end
    return kmv.values
end

Base.isempty(kmv::xKMV) = isempty(kmv.values)

function Base.length(kmv::xKMV{k}) where k
    !isempty(kmv) || return 0
    return round(Int, (k-1)/max(kmv))
end

Base.empty!(kmv::xKMV) = (empty!(kmv.values); kmv)
#= a = xKMV{100}([0, 1, 2])
push!(a, 4)
N = 10000000
push!(a, [randn() for i in 1:N])
println("N=$N vs estimation=$(length(a)).   Error relativo: $(100*abs(length(a)-N)/N) %")

 =#