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

function set_VM(dir, scaling, σ)
    τ = deg2rad(scaling * σ)^2
    κ = 1 / maximum([τ, 1e-9]) # avoid loss of precision
    return VonMises(dir, κ)
end

"""
	update!(p, current, env, erange, VM)

Returns the next position for a migration step from the `current_island` and `current_group`, updating the probability vector `p`.

# Arguments
- `p`: Probability vector to be updated in-place
- `current`: Current island position
- `env`: Island environment containing distance and angle information
- `erange`: Effective range for migration
- `VM`: Von Mises distribution for directional preference
"""
function update!(p, current, env, erange, VM)
    # Maybe pass probability vector p as function argument? we could then in-place modify it each time
    Δ = mig_index(distances(env), from=current, to=candidates)
    α = mig_index(angles(env), from=current, to=candidates)
    @. α[!Base.isbetween(mean(VM) - pi/2, α, mean(VM) + pi/2)] = -Inf

    @. Δ = Δ <= erange
    @. α = alt_adjust_VM(VM, α) / pdf(VM, mean(VM))
    @. p = α * Δ

    stayed = rand(Bernoulli(prod(1 .- p)))
    if stayed
        fill!(p, zero(eltype(p)))
        p[current] = oneunit(eltype(p))
        return p
    end
    return p
end

function probabilities(current_island, candidate_islands, env::IslandEnvironment, erange, VM)
    Δ, α = [mig_index(f(env), from=current_island, to=candidates)[candidate_islands] for f in [distances, angles]]
    p_Δ = Δ .<= erange
    p_α = alt_adjust_VM.(VM, α) ./ pdf.(VM, mean.(VM))
    p = p_α .* p_Δ

    xx = zeros(size(distances(env), 1))
    xx[candidate_islands] .= p # maybe slow

    norm_p = normalize(xx, 1)
    !all(isnan, norm_p) && return rand(Categorical(norm_p))

    p = zeros(size(distances(env), 1))
    p[current_island] = oneunit(eltype(p))
    return rand(Categorical(p))
end
