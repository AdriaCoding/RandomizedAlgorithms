using Plots

ln(x) = log(x)
Δ(ν) = 2*(60 * ln(1 - ν)*ν^6 - 360 * ln(1 - ν)*ν^5 - 140*ν^6 + 780 * ln(1 - ν)*ν^4 + 480*ν^5 - 840 * ln(1 - ν)*ν^3 - 635 * ν^4 + 504 * ln(1 - ν) * ν^2 + 428* ν^3 - 168 * ln(1 - ν)* ν - 156* ν^2 + 24 * ln(1 - ν) + 24*ν)
Q(a, ν) = (ν^4 - 4*ν^3 + 4*ν^2 - 2*ν + a) * (1 - ν)^2*ln(1 - ν)
Q(ν) = Q(0.5, ν)

function ρ(𝐀::AbstractVector, ν)
    sum = 0; i = 0
    for a_i in 𝐀[end:-1:1,end:-1:1] #traverse in opposite order
        sum += a_i*ν^i
        i+=1
    end
    return sum
end
𝒞_1(ν) = ρ([20, -120, 260, -264, 144, -40, 4], ν)

𝒞_3(ν) = 48*Q(ν)*(ln(ν) - ln(1 - ν)) + ρ([90, -308, 510, -560, 408, -176, 32], ν) * ln(1 - ν) + ρ([-110, 380, -506, 344, -132, 24], ν)*ν*ln(ν) + ρ([45, -40, -125, 212, -136, 32], ν)*ν

𝒞_4(ν) = -48*Q(ν)*ln(1 - ν) + ρ([198, -956, 1890, -2000, 1236, -440, 68], ν)*ln(1 - ν)-(20/3)*ν^9 + 30*ν^8 - (170/3) * ν^7 + (1/3) *ρ([-456, 2352, -3641, 2756, -1146, 204], ν)*ν

𝒞_5(ν) = 192*Q(3/8, ν) + ρ([-450, 1540, -2034, 1368, -492, 72], ν)*ν

C_1(ν) = ν != 0 ? 𝒞_1(ν) / Δ(ν) : error("Cannot evaluate ν == 0")
C_2(ν) = 2
C_3(ν) = ν != 0 ? 𝒞_3(ν) / Δ(ν) : error("Cannot evaluate ν == 0")
C_4(ν) = ν != 0 ? 𝒞_4(ν) / Δ(ν) : error("Cannot evaluate ν == 0")
C_5(ν) = ν != 0 ? 𝒞_5(ν) / Δ(ν) : error("Cannot evaluate ν == 0")
#TODO
C_6(ν) = 3/2 
h(x) = -x*ln(x) - (1-x)*ln(1-x)
f1(x, ν) = C_1(ν)*(1/6 * x^3 + 1/2 * x^2 - x - (1-x)*ln(1-x)) + C_2(ν)*h(x) + C_3(ν)*x + C_6(ν)
f2(x, ν)  = C_4(ν) + C_5(ν) * h(x)
function f(x::AbstractFloat, ν::AbstractFloat)
    if (ν ≤ x && x ≤ 1-ν); return f2(x, ν)
    elseif (x < ν); return f1(x, ν)
    elseif (x > 1- ν); return f1(1-x, ν)
    else; error("Invalid funcion arguments ($x, $ν)")
    end
end
f(x) = f(x, 0.265) # optimal value

#= p1 = plot(range(0,1,length=100), [𝒞_1, 𝒞_3, 𝒞_4, 𝒞_5], layout=(4, 1), legend=false)
p2 = plot(range(0,1,length=100), Δ)
p3 = plot(range(0.01,1,length=100), [C_1, C_2, C_3, C_4, C_5], layout=(5, 1), legend=false)
 
x = range(0, 1,length=100)

p5 = plot(x, f.(x,0.1), label="ν = $(0.1)")
plot!(x, f.(x,0.2), label="ν = $(0.2)")
plot!(x, f.(x,0.3), label="ν = $(0.3)")
plot!(x, f.(x,0.4), label="ν = $(0.4)")

savefig(p5, "theoretical.svg")
=#