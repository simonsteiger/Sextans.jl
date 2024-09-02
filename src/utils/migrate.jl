# TODO put these into an Axioms type
const default_precision = 120
const max_range = 5000
SigAngl = Sigmoid(1, 0.95, -4, 0.5)
SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

function isstuck(m, i)
    i < m.axioms.min_iter && return false
    return m.axioms.local_threshold >= length(unique(last(history(m), 10)))
end

arrived(m) = m isa TargetedMigration ? current(m) in m.finish_group : false

to_finite(x) = isfinite(x) ? x : zero(x)

"""
	migrate!(m::AbstractMigration, a::AbstractAgent, pe::AbstractEnvironment)

Returns the simulated migration of type `T` of `agent` in physical environment `pe`.
"""
function migrate!(mig::AbstractMigration, agent::AbstractAgent)
    E = Exponential(distances(mig.env)[finish(mig), start(mig)] / 2) # TODO give the number 2 a name, make it an axiom
    i = 1

    total_distance = distances(mig.env)[finish(mig), start(mig)]
    SigPrecision = Sigmoid(1, 0.99, 10, range(agent) / total_distance)
    
    while i < mig.axioms.max_iter && !(arrived(mig) || isstuck(mig, i))
        dir = direction(mig)
        current_pos = current(mig)

        eff_range = erange(agent, mig.energy[end])
        d_to_f = distances(mig.env)[finish(mig), current_pos]

        σ = mig.axioms.default_precision * evaluate(SigPrecision, d_to_f, total_distance)

        xx = isfinite(d_to_f) ? cdf(E, d_to_f) : 1.0
        p = probabilities(current_pos, mig.env, eff_range, dir, σ, xx)
        target_pos = rand(Categorical(p))
        d = distances(mig.env)[target_pos, current_pos]

        drain = minimum([1.0, to_finite(d) / range(agent)])
        push!(mig.energy, minimum([1.0, mig.energy[end] - drain + 0.2])) # mig.env.axioms.hab_qual[target_pos] --> TODO make a vector with a value for each island to represent its habitat quality
        push!(mig.travelled, to_finite(d))
        push!(history(mig), target_pos)

        i += 1
    end

    return mig
end
