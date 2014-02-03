// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Balance.lua
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

---I organized all of the Balance Parameters into these files.
--Ideally it would be nice to have each and every value sorted by entity or parameter. Then
--these objects would be sorted by its function in the macro micro scheme. These should be matched up with some sort of
--rts counterpart. 
--I will attempt to do this in the future when I ethier manually list all of these values or find a way to autmate a list
--with there current values. 
--If anyone see this and wants to talk or help contact me LifesFun :D at dejong.nk@gmail.com
--Thanks!
Script.Load("lua/Balance/Health.lua")
Script.Load("lua/Balance/Damage.lua")
Script.Load("lua/Balance/Costs.lua")
Script.Load("lua/Balance/Commander.lua")
Script.Load("lua/Balance/Misc.lua")
Script.Load("lua/Balance/Unused.lua")

kResearchMod = 1
// used as fallback
kDefaultBuildTime = 8
kAutoBuildRate = 0.3

--Commanders
// commanders wont receive personal resources for X seconds after logging out
kCommanderResourceBlockTime = 0
// commander has  to stay in command structure for the first kCommanderMinTime seconds of each round
kCommanderMinTime = 0
kCommanderInitialIndivRes = 0
// setting to true will prevent any placement and construction of marine structures on infested areas
kPreventMarineStructuresOnInfestation = false
kCorrodeMarineStructureArmorOnInfestation = true
kInfestationCorrodeDamagePerSecond = 15
kAlienStructureMoveSpeed = 1.5
kShiftStructurespeedScalar = 1

// Time spawning alien player must be in egg before hatching
kAlienSpawnTime = 1
kAlienSpawnTime = 10
kEggGenerationRate = 9
kAlienEggsPerHive = 3

kMarineRespawnTime = 9
kRecycleTime = 6
kItemStayTime = 30    // NS1

kResourceTowerResourceInterval = 6
kTeamResourcePerTick = 1
kPlayerResPerInterval = 0.1 // was 1.25, but players now also get res while dead
kMaxTeamResources = 250
kPlayingTeamInitialTeamRes = 60
kMaxPersonalResources = 100
kPlayerInitialIndivRes = 25

kMaxSupply = 250
kSupplyPerTechpoint = 100
kHiveBiomass = 1

kMACSupply = 5
kArmorySupply = 10
kARCSupply = 15
kSentrySupply = 5
kRoboticsFactorySupply = 0
kInfantryPortalSupply = 0
kPhaseGateSupply = 15
kDrifterSupply = 5
kWhipSupply = 10
kCragSupply = 10
kShadeSupply = 10
kShiftSupply = 10



