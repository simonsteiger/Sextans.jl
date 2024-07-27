@testset "Constructor" begin
    @test agent isa AbstractAgent
    @test agent isa ActiveAgent
    @test !isa(agent, PassiveAgent)
end

@testset "Field access" begin
    @test Sextans.range(agent) isa Real
    @test flightspeed(agent) isa Real
    @test resistance(agent) isa Real
end