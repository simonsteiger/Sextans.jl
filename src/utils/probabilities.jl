SigDist = Sigmoid(1.0, 1.0 - eps(), -10.0, sqrt(2))

function alt_adjust_VM(d, r)
    rs = [r, r + 360, r - 360]
    return maximum(pdf.(d, rs))
end

# start to finish (total journey km T)
# replace inv(i) with
# ccdf(Exponential(T/2), d_to_f)
# mutliply with default precision as is

const candidates = (:)

"""
	probabilities(current, env, erange, dir)

Returns the probability vector for transitioning from the `current` position to the targets stored in `env`. This depends on the effective range `erange` and the direction `dir` of the migration.
"""
function probabilities(current_island, current_group, env::GroupEnvironment, erange, dir, σ, prox_scaler)
    τ = deg2rad(prox_scaler * σ)^2
    κ = 1 / maximum([τ, 1e-9])
    Δ = mig_index(distances(env), from=current_island, to=candidates)
    α = mig_index(angles(env), from=current_island, to=candidates)
    p_Δ = Δ .<= erange
    VM = VonMises.(dir, κ)
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ
    stayed = rand(Bernoulli(prod(1 .- p)))
    if stayed
        p = zero(p)
        p[current_group] = oneunit(eltype(p))
        return p
    end
    return normalize(p, 1)
end

function probabilities(current_island, candidate_islands, env::IslandEnvironment, erange, dir, σ, prox_scaler)
    τ = deg2rad(prox_scaler * σ)^2
    κ = 1 / maximum([τ, 1e-9])
    Δ = mig_index(distances(env), from=current_island, to=candidate_islands)
    α = mig_index(angles(env), from=current_island, to=candidate_islands)
    p_Δ = Δ .<= erange
    VM = VonMises.(dir, κ)
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ

    xx = zeros(size(distances(env), 1))
    xx[candidate_islands] .= p

    out = normalize(xx, 1)
    !all(isnan, out) && return out

    p = zeros(size(distances(env), 1))
    p[current_island] = oneunit(eltype(p))
    return p
end
