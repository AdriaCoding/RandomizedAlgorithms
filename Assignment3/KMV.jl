import DataStructures: SortedSet
struct MyKMV{k}
    values::SortedSet{UInt8}
    function MyKMV{k}() where k
        isa(k, Integer) || throw(ArgumentError("k must be an integer"))
        return new(SortedSet{UInt8}(Base.Order.Reverse))
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
MyKMV{3}([0x00, 0x02, 0x01])

