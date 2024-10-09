__precompile__(true)

module Sextans

using Distributions
using Base: -, +
using Chain
using DataFrames
using Distances
using LinearAlgebra

export Angle, value, -, polarangle
export Sigmoid, evaluate
export Axioms

export AbstractAgent, PassiveAgent, ActiveAgent
export lifespan, range, flightspeed, resistance, energy

export AbstractEnvironment, ProtoEnvironment, GroupEnvironment, IslandEnvironment
export angles, distances

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
include("utils/sigmoid.jl")
include("utils/erange.jl")
include("utils/migrate.jl")
include("utils/probabilities.jl")

end
