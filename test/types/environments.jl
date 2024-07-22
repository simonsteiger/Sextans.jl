
@testset "Constructor" begin
    @test Env isa AbstractEnvironment
end

@testset "Field access" begin
    @test angles(Env) isa AbstractMatrix
    @test distances(Env) isa AbstractMatrix
    @test winds(Env) isa AbstractMatrix
    @test latlon(Env) isa Vector{NTuple{2, Float64}}
    @test groups(Env) isa AbstractVector
end
