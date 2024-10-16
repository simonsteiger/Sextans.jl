"""
	AbstractMigration

Abstract supertype of different migration types.
"""
abstract type AbstractMigration end

tiedindex(x) = [findfirst(==(v), unique(x)) for v in x]

"""
    get_finish(env::Environment, idx)

Retrieve the group of islands that share the same group value as the island at index `idx`.

# Arguments
- `env::Environment`: The environment containing the island groups.
- `idx`: The index of the island for which to find the group.
"""
function get_finish(env::ProtoEnvironment, idx)
    out = eachindex(env.groups)[env.groups[idx].==env.groups]
    if out isa Integer
        return [out]
    end
    return out
end

"""
    TargetedMigration <: AbstractMigration

Represents a targeted migration in the environment.

# Fields
- `axioms::Axioms`: The axioms governing the migration.
- `env::Environment`: The environment in which the migration takes place.
- `start::Int64`: The island where the migration begins.
- `target::Int64`: The island targeted during migration.
- `finish::Int64`: The index of the islands where the migration will end.
- `history::Vector{Int64}`: The history of visited islands.
- `travelled::Vector{Float64}`: The distances travelled between each step.
- `energy::Vector{Float64}`: The energy levels at each step of the migration.

# Constructor
    TargetedMigration(env, start::Integer, finish::Integer, axioms)

Constructs a TargetedMigration with the given environment, start island, finish group, and axioms.
"""
struct TargetedMigration <: AbstractMigration
    axioms::Axioms
    env::Environment
    start::Int64
    target::Int64
    finish::Vector{Int64}
    history::Vector{Int64}
    travelled::Vector{Float64}
    energy::Vector{Float64}
    function TargetedMigration(proto, start::Integer, target::Integer, axioms)
        history = [start]
        env = Environment(proto, start)
        finish = get_finish(proto, target)
        return new(axioms, env, start, target, finish, history, [], [1.0])
    end
end

start(x::AbstractMigration) = x.start_island

target(x::TargetedMigration) = x.target

mig_index(X; from, to) = X[to, from]

direction(x::TargetedMigration) = mig_index(angles(x.env), from=current(x), to=target(x))

"""
	travelled(x::AbstractMigration)

Returns the current total `travelled` distance of the migration `x`.
"""
travelled(x::AbstractMigration) = x.travelled

"""
	history(x::AbstractMigration)

Returns the `history` of an AbstractMigration `x`.
"""
history(x::AbstractMigration) = x.history

"""
	current(x::AbstractMigration)

Returns the row-index of the `current` location.
"""
current(x::AbstractMigration) = history(x)[end]
