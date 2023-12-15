import DataStructures: SortedSet
struct MyKMV{k}
    values::SortedSet{Float64}
    function MyKMV{k}() where k
        isa(k, Integer) || throw(ArgumentError("k must be an integer"))
        return new(SortedSet{Float64}(Base.Order.Reverse))
    end
    function MyKMV{k}(initial_values) where k
        kmv = MyKMV{k}()
        for v in initial_values
            push!(kmv, v)
        end
        return kmv
    end
end

MyKMV() = MyKMV{3}()

Base.max(kmv::MyKMV) = first(kmv.values)

function Base.push!(kmv::MyKMV{k}, x) where {k}
    h = (hash(x)/(1<<63-1))/2
    if length(kmv.values) < k
        insert!(kmv.values, h)
    elseif h < max(kmv)
        insert!(kmv.values, h)
        pop!(kmv.values)
    end
    return kmv.values
end

function Base.push!(kmv::MyKMV, v::AbstractArray)
    for item in v
        push!(kmv, item)
    end
    return kmv.values
end

function Base.push!(kmv::MyKMV, entries...)
    for entry in entries
        push!(kmv, entry)
    end
    return kmv.values
end

Base.isempty(kmv::MyKMV) = isempty(kmv.values)

function Base.length(kmv::MyKMV{k}) where k
    !isempty(kmv) || return 0
    return round(Int, (k-1)/max(kmv))
end

Base.empty!(kmv::MyKMV{k}) where k = (empty!(kmv.values); kmv)
#= a = MyKMV{100}([0, 1, 2])
push!(a, 4)
N = 10000000
push!(a, [randn() for i in 1:N])
println("N=$N vs estimation=$(length(a)).   Error relativo: $(100*abs(length(a)-N)/N) %")

 =#