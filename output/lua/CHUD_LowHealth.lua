Script.Load("lua/Class.lua")

Script.Load("lua/DSPEffects.lua")
local originalDSPEff
originalDSPEff = UpdateDSPEffects
function UpdateDSPEffects()
	/*if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		originalDSPEff()
	end*/
end

function OnCommandCHUDLowHealth()
	if Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
		Client.SetOptionBoolean("CHUD_LowHealthEff", false)	
		Shared.Message("Low health effects disabled.")		
	else
		Client.SetOptionBoolean("CHUD_LowHealthEff", true)
		Shared.Message("Low health effects enabled.")
	end
end

//Event.Hook("Console_chud_lowhealth", OnCommandCHUDLowHealth)