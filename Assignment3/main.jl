module Cardinality
export HyperLogLog
include("hyperloglog/hyperloglog.jl")
end
N = 100000; P = 18
hll = HyperLogLog{P}()
for i in 1:N; push!(hll, i); end
length(hll)