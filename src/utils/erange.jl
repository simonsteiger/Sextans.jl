"""
	erange(agent, travelled)

Returns the effective range of the `agent` given the distance it has `travelled`.
"""
function erange(agent::ActiveAgent, travelled)
	return range(agent) - sum(travelled)
end

# energy for max non-stop travel distance
# with travel distance, urge to refuel increases linearly (?)
# ...

# refuel adds eg 50% to remaining range (% depending on habitat quality)

# TODO need an equivalent for passive agents