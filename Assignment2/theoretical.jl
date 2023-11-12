# Math comes from at paper 3-Adaptive-sampling-strategies-for-quickselects
# Section 7 and appendix D.
ln(x) = log(x)
Δ(ν) = 2*(60 * ln(1 - ν)*ν^6 - 360 * ln(1 - ν)*ν^5 - 140*ν^6 + 780 * ln(1 - ν)*ν^4 + 480*ν^5 - 840 * ln(1 - ν)*ν^3 - 635 * ν^4 + 504 * ln(1 - ν) * ν^2 + 428* ν^3 - 168 * ln(1 - ν)* ν - 156* ν^2 + 24 * ln(1 - ν) + 24*ν)
Q(a, ν) = (ν^4 - 4*ν^3 + 4*ν^2 - 2*ν + a) * (1 - ν)^2*ln(1 - ν)
Q(ν) = Q(0.5, ν)

# parses de array of coeffs found in the paper and output the
# value of the polynomial p(ν) = a_n ⋅ ν^n + ... + a_1 ⋅ ν + a_0
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

C_1(ν) = ν != 0 ? 𝒞_1(ν) / Δ(ν) : error("C_1 cannot evaluate ν == 0")
C_2(ν) = 2
C_3(ν) = ν != 0 ? 𝒞_3(ν) / Δ(ν) : error("C_3 cannot evaluate ν == 0")
C_4(ν) = ν != 0 ? 𝒞_4(ν) / Δ(ν) : error("C_4 cannot evaluate ν == 0")
C_5(ν) = ν != 0 ? 𝒞_5(ν) / Δ(ν) : error("C_5 cannot evaluate ν == 0")
C_6(ν) = 3/2 

h(x) = (x==0.0 || x==1.0) ? 0.0 : -x*ln(x) - (1-x)*ln(1-x)

f1(x, ν) = C_1(ν)*(1/6 * x^3 + 1/2 * x^2 - x - (1-x)*ln(1-x)) + C_2(ν)*h(x) + C_3(ν)*x + C_6(ν)
f2(x, ν)  = C_4(ν) + C_5(ν) * h(x)

f(x) = f(x, 0.265) # return optimal value by default
function f(x::AbstractFloat, ν::AbstractFloat)
    if (ν ≤ x && x ≤ 1-ν); return f2(x, ν)
    elseif (x < ν); return f1(x, ν)
    elseif (x > 1- ν); return f1(1-x, ν)
    else; error("Invalid funcion arguments ($x, $ν)")
    end
end
