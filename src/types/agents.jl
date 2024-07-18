# TODO think about what methods need to be defined for an agent to work in the current pipeline
# I think this isn't even homogenous for our own two types - we won't be able to call range on a PassiveAgent for example
# Can we solve this with the Holy Trait Pattern or do we need two methods of migrate?
# The latter would kind of suck
"""
	AbstractAgent

Abstract supertype for active and passive agents.
"""
abstract type AbstractAgent end

"""
	PassiveAgent

Stores attribute `lifespan` of a passive agent, which could be a plant part.

# Examples

```julia-repl
julia> lifespan = 72 # in hours

julia> PassiveAgent(lifespan)
```
"""
struct PassiveAgent <: AbstractAgent
	lifespan
end

"""
	lifespan(x::PassiveAgent)

Return the `lifespan` of agent `x`.
"""
lifespan(x::PassiveAgent) = x.lifespan

"""
	ActiveAgent

Stores attributes `range`, `flightspeed`, `resistance` to wind, and `energy` of an active agent, which could be a bird or insect.

# Examples

```julia-repl
julia> range = 200; # in km

julia> flightspeed = 60; # in km/h

julia> resistance = 4;

julia> energy = missing;

julia> ActiveAgent(range, flightspeed, resistance, energy);
```
"""
struct ActiveAgent <: AbstractAgent
	range
	flightspeed
	resistance
	energy
end

"""
	range(x::ActiveAgent)

Return the `range` of agent `x`.
"""
range(x::ActiveAgent) = x.range

"""
    flightspeed(x::ActiveAgent)

Return the `flightspeed` of agent `x`.
"""
flightspeed(x::ActiveAgent) = x.flightspeed

"""
	resistance(x::ActiveAgent)

Return the `resistance` of agent `x`.
"""
resistance(x::ActiveAgent) = x.resistance

"""
	energy(x::ActiveAgent)

Return the `energy` of agent `x`.
"""
energy(x::ActiveAgent) = x.energy
