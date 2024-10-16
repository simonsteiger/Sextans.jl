# TODO put these into an Axioms type
const default_precision = 120
const max_range = 5000
SigAngl = Sigmoid(1, 0.95, -4, 0.5)
SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

# TODO check this one!
function isstuck(m, i)
    i < m.axioms.min_iter && return false
    return m.axioms.local_threshold >= length(unique(last(history(m), 10)))
end

arrived(m, current) = current in m.env.finish

force_finite(x) = isfinite(x) ? x : zero(x)

"""""
    migrate!(m::AbstractMigration, a::AbstractAgent, pe::AbstractEnvironment)

Simulates the migration of an agent within a given environment.

# Arguments
- `m::AbstractMigration`: The migration object containing migration parameters and state.
- `a::AbstractAgent`: The agent performing the migration.
- `pe::AbstractEnvironment`: The physical environment in which the migration occurs.

# Returns
An updated migration object with the simulated path and energy levels.
"""
function migrate!(mig::AbstractMigration, agent::AbstractAgent)
    d_start_target = mig_index(distances(mig.env), from=start(mig), to=target(mig))

    E = Exponential(d_start_target / 2) # TODO give the number 2 a name, make it an axiom
    i = 1

    SigPrecision = Sigmoid(1, 0.99, 10, range(agent) / d_start_target)

    while i < mig.axioms.max_iter && !(arrived(mig, history[end]) || isstuck(mig, i))
        current_island = current(mig)

        eff_range = erange(agent, mig.energy[end])
        d_current_target = mig_index(distances(mig.env_group), from=current_island, to=target(mig))

        σ = mig.axioms.default_precision * evaluate(SigPrecision, d_current_target, 2 * range(agent))
        prox_scaling = isfinite(d_current_target) ? cdf(E, d_current_target) : 1.0
        VM = set_VM(direction(mig), prox_scaling, σ)

        # TODO initialise p in advance
        next_step = step!(current_island, group_history[end], mig.env_group, eff_range, VM)
        push!(group_history, next_step)

        # second probabilities step TODO REMOVE
        target_group_bv = target_group .== mig.env_island.groups
        candidate_islands = eachindex(mig.env_island.groups)[target_group_bv]
        target_island = probabilities(current_island, candidate_islands, mig.env_island, eff_range, VM)

        # TODO rename to d_current_next
        d_current_target = mig_index(distances(mig.env_island), from=current_island, to=target_island)

        drain = minimum([1.0, force_finite(d_current_target) / range(agent)])
        push!(mig.energy, minimum([1.0, mig.energy[end] - drain + 0.2])) # mig.env.axioms.hab_qual[target_pos] --> TODO make a vector with a value for each island to represent its habitat quality
        push!(mig.travelled, force_finite(d_current_target))
        push!(history(mig), target_island)

        i += 1
    end

    return mig
end
