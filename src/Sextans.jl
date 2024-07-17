module Sextans

using Distributions
using Random: rand, AbstractRNG, Random, default_rng
using Base: -, +

export polar, Polar, rand
export Sigmoid, evaluate
export Angle, value, -, polarangle

include("utils/polar_normal.jl")
include("utils/sigmoid.jl")

end
