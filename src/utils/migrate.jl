# TODO check this one!
function isstuck(m, i)
    i < m.axioms.min_iter && return false
    return m.axioms.local_threshold >= length(unique(last(history(m), 10)))
end

arrived(m, current) = current in m.finish

force_finite(x) = isfinite(x) ? x : zero(x)

function keep_top_k!(x::AbstractArray{Float64}, k::Int)
    # Find indices of k largest elements
    top_k_indices = partialsortperm(x, 1:k, rev=true)
    
    # Create a mask of zeros
    mask = zeros(length(x))
    
    # Set the positions of top k elements to 1
    mask[top_k_indices] .= 1
    
    # Multiply original vector by mask in-place
    x .*= mask
    
    return x
end

"""""
    migrate!(m::AbstractMigration, a::AbstractAgent, pe::AbstractEnvironment)

Simulates the migration of an agent within a given environment.

# Arguments
- `m::AbstractMigration`: The migration object containing migration parameters and state.
- `a::AbstractAgent`: The agent performing the migration.
- `pe::AbstractEnvironment`: The physical environment in which the migration occurs.
"""
function migrate!(mig::AbstractMigration, agent::AbstractAgent)
    d_start_target = mig_index(distances(mig.env), from=start(mig), to=target(mig))
    E = Exponential(d_start_target / 2) # TODO give the number 2 a name, make it an axiom
    SigPrecision = Sigmoid(1, 0.99, 10, range(agent) / d_start_target)
    p = zeros(size(distances(mig.env)[:, 1], 1))
    i = 1

    while i < mig.axioms.max_iter && !(arrived(mig, current(mig)) || isstuck(mig, i))
        current_island = current(mig)

        eff_range = erange(agent, mig.energy[end])
        d_current_target = mig_index(distances(mig.env), from=current_island, to=target(mig))

        σ = mig.axioms.default_precision * evaluate(SigPrecision, d_current_target, 2 * range(agent))
        prox_scaling = isfinite(d_current_target) ? cdf(E, d_current_target) : 1.0
        VM = set_VM(direction(mig), prox_scaling, σ)

        update!(p, current_island, mig.env, eff_range, VM)
        next_island = rand(Categorical(normalize!(keep_top_k!(p, 5), 1.0)))

        d_current_next = mig_index(distances(mig.env), from=current_island, to=next_island)
        drain = min(1.0, force_finite(d_current_next) / range(agent))

        push!(mig.energy, 1.0) # mig.env.axioms.hab_qual[target_pos] --> TODO make a vector with a value for each island to represent its habitat quality
        push!(mig.travelled, force_finite(d_current_next))
        push!(history(mig), next_island)

        i += 1
    end

    return mig
end
