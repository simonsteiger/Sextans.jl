SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

function alt_adjust_VM(d, r)
    rs = [r, r + 360, r - 360]
    return maximum(pdf.(d, rs))
end

# start to finish (total journey km T)
# replace inv(i) with
# ccdf(Exponential(T/2), d_to_f)
# mutliply with default precision as is

"""
	probabilities(current, env, erange, dir)

Returns the probability vector for transitioning from the `current` position to the targets stored in `env`. This depends on the effective range `erange` and the direction `dir` of the migration.
"""
function probabilities(current_island, current_group, env::GroupEnvironment, erange, dir, σ, xx) # effective range used
    κ = 1 / (deg2rad(xx * σ)^2)
    Δ = @view distances(env)[:, current_island]
    α = @view angles(env)[:, current_island]
    p_Δ = Δ .<= erange
    VM = VonMises.(dir, κ)
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ
    stayed = rand(Bernoulli(prod(1 .- p)))
    if stayed
        p = zero(p)
        p[current_group] = 1
        return p
    end
    return normalize(p, 1)
end

function probabilities(current_island, candidate_islands, env::IslandEnvironment, erange, dir, σ, prox_scaler) # effective range used
    κ = 1 / (deg2rad(prox_scaler * σ)^2)
    Δ = @view distances(env)[candidate_islands, current_island]
    α = @view angles(env)[candidate_islands, current_island]
    p_Δ = Δ .<= erange
    VM = VonMises.(dir, κ)
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ
    @info p
    out = normalize(p, 1)
    @info out
    # stayed = rand(Bernoulli(prod(1 .- p)))
    # if stayed
    #     p = zero(p)
    #     p[current_island] = 1
    #     return p
    # end
    return out
end
