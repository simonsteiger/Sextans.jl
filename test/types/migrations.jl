#=
@testset "Constructor" begin
    @test mig isa AbstractMigration
end

@testset "Direction" begin
    @test Sextans.direction(mig) isa Float64
    @test !(Angle(Sextans.direction(mig)) isa DomainError)
end
=#

@testset "Finish group" begin
    @test Sextans.tiedindex(["C", "C", "A", "B"]) == [1, 1, 2, 3]
    # @test Sextans.get_finish(["C", "C", "B", "A"], 1) == [1, 2] # needs to be rewritten for Proto as input
end

@testset "Migrate" begin
    @test [migrate!(mig, agent) for mig in migs] isa AbstractArray{<:AbstractMigration}
end
