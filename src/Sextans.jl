module Sextans

using Distributions
using Random: rand, AbstractRNG, Random, default_rng
using Base: -, +

export polar, Polar, rand
export Sigmoid, evaluate
export Angle, value, -, polarangle
export erange
export migrate, main
export probabilities

export AbstractAgent, PassiveAgent, ActiveAgent
export lifespan, range, flightspeed, resistance, energy

export AbstractEnvironment, PhysicalEnvironment
export latlon, wind, angles, distances, groups

export AbstractMigration, TargetedMigration
export start, finish, travelled, history, current

include("utils/polar_normal.jl")
include("utils/sigmoid.jl")
include("utils/erange.jl")
include("utils/migrate.jl")
include("utils/probabilities.jl")
include("types/agents.jl")
include("types/environments.jl")

end
