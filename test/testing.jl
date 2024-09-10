using Chain, CSV, DataFrames, Distances, StatsBase

df_raw = @chain begin
	joinpath(@__DIR__, "data", "environment.csv")
	CSV.read(_, DataFrame)
    subset(_, :Basin => ByRow(x -> occursin(r"pacific", lowercase(x))))
    transform(_, [:Latitude, :Longitude] => ByRow((x,y) -> (x, y)) => :latlon)
end

df_groups = @chain df_raw begin
	transform(_, :Longitude => ByRow(x -> x < 0 ? x + 360 : x) => identity)
	groupby(_, "Island Group")
	combine(_, Cols(r"itude") .=> mean => identity)
	transform(_, :Longitude => ByRow(x -> x > 180 ? x - 360 : x) => identity)
	transform(_, "Island Group" => ByRow(x -> occursin(r"START", x) ? true : false) => :invalid_target)
	transform(_, [:Latitude, :Longitude] => ByRow((x,y) -> (x, y)) => :latlon)
end
