# TODO put these into an Axioms type
const default_precision = 120
const max_range = 5000
SigAngl = Sigmoid(1, 0.95, -4, 0.5)
SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

function isstuck(m, i)
    i < m.axioms.min_iter && return false
    return m.axioms.local_threshold >= length(unique(last(history(m), 10)))
end

arrived(m, current_group) = current_group == m.finish_group

to_finite(x) = isfinite(x) ? x : zero(x)

"""
	migrate!(m::AbstractMigration, a::AbstractAgent, pe::AbstractEnvironment)

Returns the simulated migration of type `T` of `agent` in physical environment `pe`.
"""
function migrate!(mig::AbstractMigration, agent::AbstractAgent)
    E = Exponential(distances(mig.env_group)[finish(mig), start(mig)] / 2) # TODO give the number 2 a name, make it an axiom
    i = 1

    total_distance = distances(mig.env_group)[finish(mig), start(mig)]
    SigPrecision = Sigmoid(1, 0.99, 10, range(agent) / total_distance)

    group_history = [mig.env_island.groups[start(mig)]] # maybe there's a better way... track this, too?
    
    while i < mig.axioms.max_iter && !(arrived(mig, group_history[end]) || isstuck(mig, i))
        dir = direction(mig)
        current_island = current(mig)

        eff_range = erange(agent, mig.energy[end])
        d_to_f = distances(mig.env_group)[finish(mig), current_island]

        σ = mig.axioms.default_precision * evaluate(SigPrecision, d_to_f, 2 * range(agent))

        prox_scaler = isfinite(d_to_f) ? cdf(E, d_to_f) : 1.0

        p_group = probabilities(current_island, group_history[end], mig.env_group, eff_range, dir, σ, prox_scaler)
        target_group = rand(Categorical(p_group))
        push!(group_history, target_group)

        # second probabilities step
        target_group_bv = target_group .== mig.env_island.groups
        target_indices = eachindex(mig.env_island.groups)[target_group_bv]
        p_island = probabilities(current_island, target_group_bv, mig.env_island, eff_range, dir, σ, prox_scaler)
        target_island = target_indices[rand(Categorical(p_island))]
        d = distances(mig.env_island)[target_island, current_island]

        drain = minimum([1.0, to_finite(d) / range(agent)])
        push!(mig.energy, minimum([1.0, mig.energy[end] - drain + 0.2])) # mig.env.axioms.hab_qual[target_pos] --> TODO make a vector with a value for each island to represent its habitat quality
        push!(mig.travelled, to_finite(d))
        push!(history(mig), target_island)

        i += 1
    end

    return mig
end
