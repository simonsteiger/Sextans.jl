# TODO put these into an Axioms type
const default_precision = 120
const max_range = 5000
SigAngl = Sigmoid(1, 0.95, -4, 0.5)
SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

"""
	ismigrating(history, i)

Returns a `Boolean` value signalling whether the migration is still ongoing at step `i`.
"""
function ismigrating(m, i)
    i < m.axioms.min_iter && return true
    isstuck = length(unique(last(history(m), 10))) > m.axioms.local_threshold
    return isstuck
end

# ╔═╡ 362723f8-64b0-49ea-9bd4-20fda8286132
function notarrived(m::T) where {T<:AbstractMigration}
    T != TargetedMigration && return true # Untargeted never arrived
    return current(m) ∉ m.finish_group
end

"""
	migrate(m::T, agent, pe::AbstractEnvironment) where T <: AbstractMigration

Returns the simulated migration of type `T` of `agent` in physical environment `pe`.
"""
function migrate!(m::T, agent, pe::AbstractEnvironment) where {T<:AbstractMigration}
    # e_env = EffectiveEnvironment(pe, agent)
    # TODO does this adjustment have to happen _INSIDE_ migrate? No, right?!
    # ATTENTION had e_env before. But e_env contains only adjustments to angles, not new angles? CAREFUL!

    # Initialise counter
    i = 1

    # σ is the adjusted precision of an agent depending on its range (larger range means higher precision)
    σ = m.axioms.default_precision * evaluate(SigAngl, range(agent), m.axioms.max_range)

    while ismigrating(m, i) && notarrived(m) && i < m.axioms.max_iter
        dir = direction(m)
        current_pos = current(m)
        
        eff_range = erange(agent, travelled(m), m.axioms.min_range)
        p = probabilities(current_pos, pe, eff_range, dir, i, σ)
        target_pos = rand(Categorical(p))
        d = distances(pe)[current_pos, target_pos]

        push!(m.travelled, isfinite(d) ? d : 0.0)
        push!(history(m), target_pos)
        
        i += 1
    end

    return m
end
