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

"""
	migrate!(m::AbstractMigration, a::AbstractAgent, pe::AbstractEnvironment)

Returns the simulated migration of type `T` of `agent` in physical environment `pe`.
"""
function migrate!(mig::AbstractMigration, agent::AbstractAgent)
    # adjusted precision of agent proportional to range, larger range is higher precision
    σ = mig.axioms.default_precision * evaluate(SigAngl, range(agent), mig.axioms.max_range)
    E = Exponential(distances(mig.env)[finish(mig), start(mig)] / 2) # TODO give the number 2 a name, make it an axiom
    i = 1
    
    while i < mig.axioms.max_iter && !(arrived(mig) || isstuck(mig, i))
        dir = direction(mig)
        current_pos = current(mig)
        
        eff_range = erange(agent, travelled(mig), mig.axioms.min_range)
        d_to_f = distances(mig.env)[finish(mig), current_pos]
        xx = isfinite(d_to_f) ? cdf(E, d_to_f) : 1.0
        p = probabilities(current_pos, mig.env, eff_range, dir, σ, xx)
        target_pos = rand(Categorical(p))
        d = distances(mig.env)[target_pos, current_pos]
        
        push!(mig.travelled, isfinite(d) ? d : 0.0)
        push!(history(mig), target_pos)
        
        i += 1
    end

    return mig
end
