Script.Load("lua/Class.lua")

Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")
local originalMarineStatusInit
originalMarineStatusInit = Class_ReplaceMethod( "GUIMarineStatus", "Initialize",
	function (self)
		originalMarineStatusInit(self)
		if CHUDSettings["mingui"] then
			self.statusbackground:SetColor(Color(1,1,1,0))
			self.scanLinesForeground:SetColor(Color(1,1,1,0))
		end
	end
)

local originalMarineStatusUpdate
originalMarineStatusUpdate = Class_ReplaceMethod( "GUIMarineStatus", "Update",
	function (self, deltaTime, parameters)
		originalMarineStatusUpdate(self, deltaTime, parameters)
		if CHUDSettings["mingui"] or not CHUDSettings["hpbar"] then
			self.healthBorderMask:SetColor(Color(1,1,1,0))
			self.armorBorderMask:SetColor(Color(1,1,1,0))
		end
		if not CHUDSettings["hpbar"] then
			self.statusbackground:SetTexturePixelCoordinates(unpack({ 0, 0, 0, 0 }))
			self.scanLinesForeground:SetAnchor(GUIItem.Left, GUIItem.Top)
			self.parasiteState:SetAnchor(GUIItem.Left, GUIItem.Center)
			self.healthText:SetPosition(Vector(-300, 36, 0))
			self.armorText:SetPosition(Vector(-300, 96, 0))
			self.healthBar:SetIsVisible(false)
			self.armorBar:SetIsVisible(false)
		end
	end
)

Script.Load("lua/Hud/GUIEvent.lua")
local originalEventUpdate
originalEventUpdate = Class_ReplaceMethod( "GUIEvent", "Update",
	function (self, deltaTime, parameters)
		if not CHUDSettings["minimap"] then
			parameters[1] = nil
		end
		originalEventUpdate(self, deltaTime, parameters)
		if CHUDSettings["mingui"] then
			self.borderTop:SetIsVisible(false)
			self.unlockBackground:SetColor(Color(1,1,1,0))
			self.unlockFlash:SetIsVisible(false)
			self.unlockFlashStencil:SetIsVisible(false)
		end
		if not CHUDSettings["unlocks"] then
			self.unlockFrame:SetIsVisible(false)
		else
			self.unlockFrame:SetIsVisible(true)
		end
	end
)

Script.Load("lua/GUIAlienTeamMessage.lua")
originalAlienMessage = Class_ReplaceMethod( "GUIAlienTeamMessage", "SetTeamMessage",
	function(self, message)
		originalAlienMessage(self, message)
		if not CHUDSettings["banners"] then
			self.background:SetIsVisible(false)
		end
		if CHUDSettings["mingui"] then
			self.background:DestroyAnimations()
		end
	end
)

Script.Load("lua/GUIMarineTeamMessage.lua")
originalMarineMessage = Class_ReplaceMethod( "GUIMarineTeamMessage", "SetTeamMessage",
	function(self, message)
		originalMarineMessage(self, message)
		if not CHUDSettings["banners"] then
			self.background:SetIsVisible(false)
		end
		if CHUDSettings["mingui"] then
			self.background:DestroyAnimations()
		end
	end
)

Script.Load("lua/Player_Client.lua")
originalBlur = Class_ReplaceMethod( "Player", "SetBlurEnabled",
	function(self, blurEnabled)
		if not CHUDSettings["blur"] then
			Player.screenEffects.blur:SetActive(false)
		else
			originalBlur(self, blurEnabled)
		end
	end
)

originalUpdateScreenEff = Class_ReplaceMethod( "Player", "UpdateScreenEffects",
	function(self, deltaTime)
		originalUpdateScreenEff(self, deltaTime)
		//if not Client.GetOptionBoolean("CHUD_LowHealthEff", true) then
			Player.screenEffects.lowHealth:SetActive(false)
		//end
	end
)