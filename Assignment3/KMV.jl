import DataStructures: SortedSet
struct MyKMV{k}
    values::SortedSet{UInt}
    function MyKMV{k}() where k
        isa(k, Integer) || throw(ArgumentError("k must be an integer"))
        return new(SortedSet{UInt}(Base.Order.Reverse))
    end
    function MyKMV{k}(initial_values) where k
        kmv = MyKMV{k}()
        k == length(initial_values) ||
            throw(ArgumentError("There must be $k initial_values"))
        for v in initial_values
            push!(kmv.values, v)
        end
        return kmv
    end
end
MyKMV() = MyKMV{3}()
a = MyKMV{3}([0x00, 0x02, 0x01])
push!(a, 4)
Base.max(kmv::MyKMV) = first(kmv.values)

function Base.push!(kmv::MyKMV{k}, x) where {k}
    h = hash(x)
    if length(kmv.values) < k
        insert!(kmv.values, h)
    elseif h < max(kmv)
        insert!(kmv.values, h)
        pop!(kmv.values)
    end
    return kmv.values
end

function Base.push!(kmv::MyKMV, entries...)
    for entry in entries
        push!(kmv, entry)
    end
    return kmv.values
end
