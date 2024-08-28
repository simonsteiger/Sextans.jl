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
function migrate!(m::AbstractMigration, a::AbstractAgent, e::AbstractEnvironment)
    i = 1

    # adjusted precision of agent proportional to range, larger range is higher precision
    σ = m.axioms.default_precision * evaluate(SigAngl, range(a), m.axioms.max_range)

    E = Exponential(distances(e)[finish(m), start(m)] / 2) # TODO give the number 2 a name, make it an axiom

    while i < m.axioms.max_iter && !(arrived(m) || isstuck(m, i))
        dir = direction(m)
        current_pos = current(m)
        
        eff_range = erange(a, travelled(m), m.axioms.min_range)
        d_to_f = distances(e)[finish(m), current_pos]
        xx = ccdf(E, d_to_f)
        p = probabilities(current_pos, e, eff_range, dir, σ, xx)
        target_pos = rand(Categorical(p))
        d = distances(e)[target_pos, current_pos]
        
        push!(m.travelled, isfinite(d) ? d : 0.0)
        push!(history(m), target_pos)
        
        i += 1
    end

    return m
end
