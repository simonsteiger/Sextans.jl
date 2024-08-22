__precompile__(true)

module Sextans

using Distributions
using Random: rand, AbstractRNG, Random, default_rng
using Base: -, +
using Chain
using DataFrames
using Distances
using LinearAlgebra

export Angle, value, -, polarangle
export polar, Polar, rand
export Sigmoid, evaluate
export Axioms

export AbstractAgent, PassiveAgent, ActiveAgent
export lifespan, range, flightspeed, resistance, energy

export AbstractEnvironment, PhysicalEnvironment
export latlon, winds, angles, distances, groups

export AbstractMigration, TargetedMigration
export start, finish, travelled, history, current

export erange
export migrate!
export probabilities

include("types/axioms.jl")
include("types/agents.jl")
include("types/environments.jl")
include("types/migrations.jl")
include("utils/angle.jl")
include("utils/polar_normal.jl")
include("utils/sigmoid.jl")
include("utils/erange.jl")
include("utils/migrate.jl")
include("utils/probabilities.jl")

end
