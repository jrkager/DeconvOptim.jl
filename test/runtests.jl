using DeconvOptim
using Test
using FFTW, Noise, Statistics, Zygote
using Random

 # fix seed for reproducibility
Random.seed!(42)

@testset "Utils" begin
    include("utils.jl")
end


include("mappings.jl")

include("forward_models.jl")

include("lossfunctions.jl")

 # testing is rather hard, but include at least some basic testing
include("regularizer.jl")

include("main.jl")
