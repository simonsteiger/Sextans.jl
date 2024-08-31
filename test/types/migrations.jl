@testset "Constructor" begin
    @test mig isa AbstractMigration
end

@testset "Field access" begin
    @test start(mig) isa Int
    @test finish(mig) isa Int
    @test current(mig) isa Int
end

@testset "Direction" begin
    @test Sextans.direction(mig) isa Float64
    @test !(Angle(Sextans.direction(mig)) isa DomainError)
end

@testset "Migrate" begin
    @test migrate!(mig, agent) isa AbstractMigration
end
