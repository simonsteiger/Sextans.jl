env = PhysicalEnvironment(proto, target)

@testset "Constructor" begin
    @test env isa AbstractEnvironment
end

@testset "Field access" begin
    @test angles(env) isa AbstractMatrix
    @test distances(env) isa AbstractMatrix
end
