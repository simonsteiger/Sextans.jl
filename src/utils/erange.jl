"""
	erange(agent, travelled)

Returns the effective range of the `agent` given the distance it has `travelled`.
"""
function erange(agent::ActiveAgent, travelled, min_range)
	return maximum([range(agent) * min_range, range(agent) - sum(travelled)])
end

# TODO need an equivalent for passive agents

# energy for max non-stop travel distance
# with travel distance, urge to refuel increases linearly (?)
# ...

# refuel adds eg 50% to remaining range (% depending on habitat quality)
