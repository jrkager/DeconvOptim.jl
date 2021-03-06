export Poisson, poisson_aux
export Gauss, gauss_aux
export ScaledGauss, scaled_gauss_aux


"""
    poisson_aux(μ, meas)

Calculates the Poisson loss for `μ` and `meas`.
`μ` can be of larger size than `meas`. In that case
we extract a centered region from `μ` of the same size as `meas`.
""" 
function poisson_aux(μ, meas)
    μ = center_extract(μ, size(meas))
    
    μ[μ .<= 1f-8] .= 1f-8
    return sum(μ .- meas .* log.(μ))
end


 # define custom gradient for speed-up
 # ChainRulesCore offers the possibility to define a backward AD rule
 # which can be used by several different AD systems
function ChainRulesCore.rrule(::typeof(poisson_aux), μ, meas)
    Y = poisson_aux(μ, meas)

    function poisson_aux_pullback(xbar)
        meas_new = copy(μ)
        meas_new = center_set!(meas_new, meas)

        ∇ = xbar .* (one(eltype(μ)) .- meas_new ./ μ)
        ∇[μ .< 1f-8] .= 0
        return zero(eltype(μ)), ∇, zero(eltype(μ)) 
    end

    return Y, poisson_aux_pullback
end


"""
    Poisson()

Returns a function to calculate Poisson loss
Check the help of `poisson_aux`.
"""
function Poisson()
      return poisson_aux
end



"""
    gauss_aux(μ, meas)

Calculates the Gauss loss for `μ` and `meas`.
`μ` can be of larger size than `meas`. In that case
we extract a centered region from `μ` of the same size as `meas`.
""" 
function gauss_aux(μ, meas)
    μ = center_extract(μ, size(meas))
    return sum(abs2.(μ - meas))
end

 # define custom gradient for speed-up
function ChainRulesCore.rrule(::typeof(gauss_aux), μ, meas)
    Y = gauss_aux(μ, meas) 
    function gauss_aux_pullback(xbar)
        meas_new = copy(μ)
        meas_new = center_set!(meas_new, meas)
        return zero(eltype(μ)), 2 .* (μ - meas_new), zero(eltype(μ)) 
    end
    return Y, gauss_aux_pullback
end


"""
    Gauss()

Returns a function to calculate Gauss loss.
Check the help of `gauss_aux`.
"""
function Gauss()
    return gauss_aux
end





"""
    scaled_gauss_aux(μ, meas)
Calculates the scaled Gauss loss for `μ` and `meas`.
`μ` can be of larger size than `meas`. In that case
we extract a centered region from `μ` of the same size as `meas`.
"""
function scaled_gauss_aux(μ, meas)
    μ = center_extract(μ, size(meas))
    μ[μ .<= 1f-8] .= 1f-8
    return sum(1/2f0 .* log.(μ) .+ (meas .- μ).^2 ./ (2 .* μ))
end

 # define custom gradient for speed-up
function ChainRulesCore.rrule(::typeof(scaled_gauss_aux), μ, meas)
    Y = scaled_gauss_aux(μ, meas) 
    function scaled_gauss_aux_pullback(xbar)
        meas_new = copy(μ)
        meas_new = center_set!(meas_new, meas)
        ∇ = (μ + μ.^2 - meas_new.^2)./(2 .* μ.^2)
        ∇[μ .<= 1f-8] .= 0 
        return zero(eltype(μ)), ∇, zero(eltype(μ)) 
    end
    return Y, scaled_gauss_aux_pullback
end


"""
    ScaledGauss()

Returns a function to calculate scaled Gauss loss.
Check the help of `scaled_gauss_aux`.
"""
function ScaledGauss()
    return scaled_gauss_aux
end
