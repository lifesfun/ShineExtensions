kDamageVelocityScalar = 2.5
kMelee1DamageScalar = 1.1
kMelee2DamageScalar = 1.2
kMelee3DamageScalar = 1.3

local kDamagePerUpgradeScalar = 0.1
kWeapons1DamageScalar = 1 + kDamagePerUpgradeScalar
kWeapons2DamageScalar = 1 + kDamagePerUpgradeScalar * 2
kWeapons3DamageScalar = 1 + kDamagePerUpgradeScalar * 3

//Marines
	kMaxTimeToSprintAfterAttack = .2

	// For power points
	kMarineRepairHealthPerSecond = 600
	// Welding variables
	// Also: MAC.kRepairHealthPerSecond
	// Also: Exo -> kArmorWeldRate

	kWelderPowerRepairRate = 220
	kBuilderPowerRepairRate = 110
	kWelderSentryRepairRate = 150
	kPlayerWeldRate = 30
	kWelderDamagePerSecond = 30
	kWelderDamageType = kDamageType.Flame
	kWelderFireDelay = 0.2
	kPlayerArmorWeldRate = 20
	kStructureWeldRate = 90
	kDoorWeldTime = 15

	// Mines
	kMineActiveTime = 4
	kMineAlertTime = 8
	kMineDetonateRange = 5
	kMineTriggerRange = 1.5
	kMineDamage = 125
	kMineDamageType = kDamageType.Light

	kPulseGrenadeDamageRadius = 8
	kPulseGrenadeEnergyDamageRadius = 10
	kPulseGrenadeDamage = 110
	kPulseGrenadeEnergyDamage = 0
	kPulseGrenadeDamageType = kDamageType.Normal
	kClusterGrenadeDamageRadius = 10
	kClusterGrenadeDamage = 110
	kClusterFragmentDamageRadius = 8
	kClusterFragmentDamage = 10
	kClusterGrenadeDamageType = kDamageType.Flame
	kNerveGasDamagePerSecond = 50
	kNerveGasDamageType = kDamageType.NerveGas

	kAxeDamage = 25
	kAxeDamageType = kDamageType.Structural

	//notin use
	kPistolMinFireDelay = 0.1
	// 10 bullets per second
	kPistolRateOfFire = 0.1
	kPistolDamage = 25
	kPistolDamageType = kDamageType.Light
	kPistolClipSize = 10

	kRifleDamage = 10
	kRifleDamageType = kDamageType.Normal
	kRifleClipSize = 50
	kRifleMeleeDamage = 10
	kRifleMeleeDamageType = kDamageType.Normal

	kGrenadeLauncherClipSize = 4
	kGrenadeLauncherGrenadeDamage = 165
	kGrenadeLauncherGrenadeDamageType = kDamageType.Structural
	kGrenadeLauncherGrenadeDamageRadius = 4.8
	kGrenadeLifetime = 2.0

	kShotgunFireRate = 0.88
	kShotgunDamage = 10
	kShotgunDamageType = kDamageType.Normal
	kShotgunClipSize = 6
	kShotgunBulletsPerShot = 17

	kFlamethrowerDamage = 15
	kFlameThrowerEnergyDamage = 3
	kBurnDamagePerSecond = 2
	kFlamethrowerDamageType = kDamageType.Flame
	kFlamethrowerClipSize = 50
	kFlamethrowerRange = 9
	kBurnDamagePerStackPerSecond = 3
	kFlamethrowerMaxStacks = 20
	kFlamethrowerBurnDuration = 6
	kFlamethrowerStackRate = 0.4
	kFlameRadius = 1.8
	kFlameDamageStackWeight = 0.5

	// Jetpack
	kUpgradedJetpackUseFuelRate = .19
	kJetpackUseFuelRate = .23
	kJetpackReplenishFuelRate = .24


	kMinigunDamage = 20
	kMinigunDamageType = kDamageType.Heavy

	kClawDamage = 30
	kClawDamageType = kDamageType.Structural

	kRailgunDamage = 30
	kRailgunChargeDamage = 130
	kRailgunDamageType = kDamageType.Structural
	// affects dual minigun and dual railgun damage output
	kExoDualMinigunModifier = 1
	kExoDualRailgunModifier = 1

	kSentryAttackDamageType = kDamageType.Normal
	kSentryAttackBaseROF = .15
	kSentryAttackRandROF = 0.0
	kSentryAttackBulletsPerSalvo = 1
	kConfusedSentryBaseROF = 2.0
	kSentryDamage = 5

	kARCDamage = 450
	kARCDamageType = kDamageType.Splash // splash damage hits friendly arcs as well
	kARCRange = 26
	kARCMinRange = 7


// ALIEN DAMAGE


//skulk
	kBiteDamage = 75
	kBiteDamageType = kDamageType.Normal
	kBiteEnergyCost = 5.85

	kLeapEnergyCost = 45

	// set to -1 for no time limit
	kParasiteDuration = 44
	kParasiteDamage = 10
	kParasiteDamageType = kDamageType.Normal
	kParasiteEnergyCost = 30

	kXenocideDamage = 200
	kXenocideDamageType = kDamageType.Normal
	kXenocideRange = 14
	kXenocideEnergyCost = 30


//gorge
	kGorgeArmorTunnelDamagePerSecond = 5
	kBellySlideCost = 25
	kHydraDamage = 15 // From NS1
	kHydraAttackDamageType = kDamageType.Normal
	kMinBuildTimePerHealSpray = 0.9
	kMaxBuildTimePerHealSpray = 1.8
	kMinWebLength = 0.5
	kMaxWebLength = 8
	// Players get energy back at this rate when on fire 
	kOnFireEnergyRecuperationScalar = 1
	kSprayDouseOnFireChance = .5

	kSpitDamage = 30
	kSpitDamageType = kDamageType.Light
	kSpitEnergyCost = 7

	kBabblerPheromoneEnergyCost = 7
	kBabblerDamage = 10
	kBabblerCost = 0
	kBabblerEggBuildTime = 8
	kNumBabblerEggsPerGorge = 3
	kNumBabblersPerEgg = 6

	// Also see kHealsprayHealStructureRate
	kHealsprayDamage = 8
	kHealsprayDamageType = kDamageType.Biological
	kHealsprayFireDelay = 0.8
	kHealsprayEnergyCost = 12
	kHealsprayRadius = 3.5

	kBileBombDamage = 55 // per second
	kBileBombDamageType = kDamageType.Corrode
	kBileBombEnergyCost = 20
	kBileBombDuration = 5
	// 200 inches in NS1 = 5 meters
	kBileBombSplashRadius = 6

	kWebBuildCost = 1
	kWebbedDuration = 2

//lerk
	
	LerkFlapEnergyCost = 3
	// Umbra blocks 1 out of this many bullet
	kUmbraBlockRate = 2
	// Carries the umbra cloud for x additional seconds
	kUmbraRetainTime = 0.25
	kkLerkSporeShootRange = 10
	kPoisonDamageThreshhold = 5

	kLerkBiteDamage = 60
	kBitePoisonDamage = 6 // per second
	kPoisonBiteDuration = 6
	kLerkBiteEnergyCost = 5
	kLerkBiteDamageType = kDamageType.Normal

	kUmbraEnergyCost = 27
	kUmbraDuration = 5
	kUmbraRadius = 6
	kUmbraShotgunModifier = 0.64
	kUmbraBulletModifier = 0.75
	kUmbraMinigunModifier = 0.70
	kUmbraRailgunModifier = 0.68

	kSpikeMaxDamage = 7
	kSpikeMinDamage = 7
	kSpikeDamageType = kDamageType.Puncture
	kSpikeEnergyCost = 1.4
	kSpikesAttackDelay = 0.07
	kSpikeMinDamageRange = 9
	kSpikeMaxDamageRange = 2
	kSpikesRange = 50
	kSpikesPerShot = 1

	kSporesDamageType = kDamageType.Gas
	kSporesDustDamagePerSecond = 20
	kSporesDustFireDelay = 0.36
	kSporesDustEnergyCost = 8
	kSporesDustCloudRadius = 2.5
	kSporesDustCloudLifetime = 8

//fade
	kSwipeDamage = 37.5
	kSwipeDamageType = kDamageType.Puncture
	kSwipeEnergyCost = 7

	kStabDamage = 160
	kStabDamageType = kDamageType.Normal
	kStabEnergyCost = 30

	kVortexEnergyCost = 20
	kVortexDuration = 3

	kFadeShadowStepCost = 11
	kStartBlinkEnergyCost = 14
	kBlinkEnergyCost = 32
	kHealthOnBlink = 0

// Onos
	kGoreMarineFallTime = 1
	kDisruptTime = 5
	// Light shaking constants
	kOnosLightDistance = 50
	kOnosLightShakeDuration = .2
	kLightShakeMaxYDiff = .05
	kLightShakeBaseSpeed = 30
	kLightShakeVariableSpeed = 30
	kChargeEnergyCost = 38 // per second

	kGoreDamage = 100
	kGoreDamageType = kDamageType.Structural
	kGoreEnergyCost = 12

	kBoneShieldEnergyPerSecond = 13
	kStartBoneShieldCost = 10

	kStompEnergyCost = 30
	kStompDamageType = kDamageType.Heavy
	kStompDamage = 40
	kStompRange = 12
	kDisruptMarineTime = 2
	kDisruptMarineTimeout = 4

	kWhipSlapDamage = 50
	kWhipBombardDamage = 250
	kWhipBombardDamageType = kDamageType.Corrode
	kWhipBombardRadius = 6
	kWhipBombardRange = 10
	kWhipBombardROF = 6

	// used for regeneration upgrade
	kAlienRegenerationTime = 2
	kAlienMinRegeneration = 6
	kAlienMaxRegeneration = 40
	kAlienRegenerationPercentage = 0.04
	// when in combat self healing (innate healing or through upgrade) is multiplied with this value
	kAlienRegenerationCombatModifier = 1

	kAlienInnateRegenerationPercentage  = 0.02
	kAlienMinInnateRegeneration = 1
	kAlienMaxInnateRegeneration = 20

	kCarapaceSpeedReduction = 0.0
	kSkulkCarapaceSpeedReduction = 0 //0.08
	kGorgeCarapaceSpeedReduction = 0 //0.08
	kLerkCarapaceSpeedReduction = 0 //0.15
	kFadeCarapaceSpeedReduction = 0 //0.15
	kOnosCarapaceSpeedReduction = 0 //0.12

	// increases max speed by 1.5 m/s
	kCelerityAddSpeed = 1.5

	kAbilityMaxEnergy = 100
	kAdrenalineAbilityMaxEnergy = 130


