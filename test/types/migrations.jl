@testset "Constructor" begin
    @test Mig isa AbstractMigration
end

@testset "Field access" begin
    @test start(Mig) isa Int
    @test finish(Mig) isa Int
    @test current(Mig) isa Int
end

@testset "Direction" begin
    @test Sextans.direction(Mig) isa Float64
    @test !(Angle(Sextans.direction(Mig)) isa DomainError)
end
