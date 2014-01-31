
//Marine

	kInitialMACs = 1
	kMACConstructEfficacy = .3
	kMACSpeedAmount = 1

	kSentriesRange = 7.0 --added 
	kSentriesPerBattery = 5

	kArmoryWeaponAttachRange = 10

	// Minimum distance that initial IP spawns away from team location
	kInfantryPortalMinSpawnDistance = 4
	kInfantryPortalAttachRange = 10
	kSpawnBlockRange = 5

//Marine micro
	kNanoShieldCost = 2
	kNanoShieldCooldown = 2
	kNanoShieldDuration = 5
	kNanoArmorHealPerSecond = 0.5
	kNanoShieldDamageReductionDamage = 0.68

	kPowerSurgeCooldown = 10
	kPowerSurgeDuration = 20
	kPowerSurgeCost = 5

	kAmmoPackCost = 1
	kMedPackCost = 1
	kMedPackCooldown = 0
	kCatPackCost = 2
	kCatPackMoveAddSpeed = 1.25
	kCatPackWeaponSpeed = 1.5
	kCatPackDuration = 5

	kStructureCircleRange = 4
	// Scanner sweep
	kScanDuration = 10
	kScanRadius = 20

	// Distress Beacon (from NS1)
	kDistressBeaconRange = 25
	kDistressBeaconTime = 3

//aliens
	kEggsPerHatch = 2 
	kHatchCooldown = 4

	kContaminationCost = 5
	kContaminationCooldown = 5
	kBoneWallCost = 2
	kBoneWallCooldown = 5

	kNutrientMistCost = 1
	kNutrientMistCooldown = 5
	// Note: If kNutrientMistDuration changes, there is a tooltip that needs to be updated.
	kNutrientMistDuration = 15
	// 100% + X (increases by 66%, which is 10 second reduction over 15 seconds)
	kNutrientMistPercentageIncrease = 66
	kNutrientMistMaturingIncrease = 66
	kNutrientMistMaturitySpeedup = 2
	kNutrientMistAutobuildMultiplier = 1

	kShadeInkCost = 2
	kShadeInkCooldown = 10
	kShadeInkDuration = 5

	kCragHealWaveCost = 2
	kHealWaveCooldown = 2

	kEchoRange = 8

//drifter
	kInitialDrifters = 0
	kDrifterHatchTime = 7
	kDrifterCost = 8
	kDrifterAbilityCooldown = 0
	kDrifterCooldown = 0

	kMucousMembraneCost = 2

	kEnzymeCloudCost = 2
	kEnzymeAttackSpeed = 1.25
	kEnzymeCloudDuration = 2

	kHallucinationCloudCost = 2
	kHallucinationCloudCooldown = 2
	kHallucinationHealthFraction = 0.33
	kHallucinationArmorFraction = 0
	kHallucinationMaxHealth = 700

	//Stuctures echo
	kEchoHydraCost = 1
	kEchoWhipCost = 2
	kEchoCragCost = 1
	kEchoShadeCost = 1
	kEchoShiftCost = 1
	kEchoVeilCost = 1
	kEchoSpurCost = 1
	kEchoShellCost = 1
	kEchoEggCost = 2
	kEchoHarvesterCost = 2
	kEchoTunnelCost = 5
	kEchoHiveCost = 10

//cysts
	kRuptureCost = 1
	kRuptureCooldown = 1

	kCystCost = 1
	kCystCooldown = 0.0

	kCystInfestDuration = 37.5
	// Cyst parent ranges, how far a cyst can support another cyst
	// NOTE: I think the range is a bit long for kCystMaxParentRange, there will be gaps between the
	// infestation patches if the range is > kInfestationRadius * 1.75 (about).
	kHiveCystParentRange = 24 // distance from a hive a cyst can be connected
	kCystMaxParentRange = 24 // distance from a cyst another cyst can be placed
	kCystRedeployRange = 6 // distance from existing Cysts that will cause redeployment
	// Damage over time that all cysts take when not connected
	kCystUnconnectedDamage = 12

// Infestation
	kGorgeInfestationLifetime = 60--not in the game?

	kMarineInfestationSpeedScalar = .1 --?
	kInfestationBuildModifier = 0.75 -- ?
	kHiveInfestationRadius = 20
	kStructureInfestationRadius = 2
	kInfestationRadius = 7.5
