Script.Load("lua/Class.lua")

local blockedCinematics = {	"cinematics/marine/structures/death_large.cinematic",
							"cinematics/marine/structures/death_small.cinematic",
							"cinematics/marine/sentry/death.cinematic",
							"cinematics/marine/infantryportal/death.cinematic",
							"cinematics/alien/cyst/enzymecloud_splash.cinematic",
							"cinematics/death_1p.cinematic",
							"cinematics/alien/death_1p_alien.cinematic",
							"cinematics/marine/commander_arrow.cinematic",
							"cinematics/alien/commander_arrow.cinematic"}
							
local replacedCinematics = {"cinematics/alien/mucousmembrane.cinematic",
							"cinematics/alien/cyst/enzymecloud_large.cinematic",
							"cinematics/alien/nutrientmist.cinematic",
							"cinematics/alien/nutrientmist_hive.cinematic",
							"cinematics/alien/nutrientmist_onos.cinematic",
							"cinematics/alien/nutrientmist_structure.cinematic",
							"cinematics/marine/spawn_item.cinematic"}
							
// Precache all the new cinematics
PrecacheAsset("chud_cinematics/blank.cinematic")
for i, cinematic in pairs(replacedCinematics) do
	PrecacheAsset(cinematic)
end

local originalSetCinematic
originalSetCinematic = Class_ReplaceMethod( "Cinematic", "SetCinematic", 
	function(self, cinematicName)
		//Print(cinematicName)
		if CHUDSettings["particles"] then
			if table.contains(replacedCinematics, cinematicName) then
				originalSetCinematic(self, "chud_" .. cinematicName)
			elseif table.contains(blockedCinematics, cinematicName) then
				originalSetCinematic(self, "chud_cinematics/blank.cinematic")
			else
				originalSetCinematic(self, cinematicName)
			end
		else
			originalSetCinematic(self, cinematicName)
		end
	end
)