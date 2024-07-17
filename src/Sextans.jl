module Sextans

using Distributions
using Random: rand, AbstractRNG, Random, default_rng

export circular, Circular, rand
export Sigmoid, evaluate

include("utils/circular.jl")
include("utils/sigmoid.jl")

end
