-- ==============================================================
--
-- Lerk Lift Mod v0.1
--    by Hackepeter
--
-- Date: 2011-10-28
--
-- Installation: place this file in ns2\lua and add to the beginning
-- of Alien_Server.lua: Script.Load("lua/LerkLiftMod.lua")
-- 
-- Admins can turn the mod at anytime (also mid game) off/on
-- with lerklift 0/1 in the server console.
--
-- ==============================================================

-- should the mod be enabled by default?
--
Alien.kLiftEnabled = true

Alien.kLiftInterval = 1

Alien.kLifterClass = "Lerk"
Alien.kLiftedClass = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftedTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLifterOnSound = "alien_vision_on"
Alien.kLifterOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( player , useSuccessTable )

	if not self:GetIsAlive() then useSuccessTable.UseSuccess = true return end
end

function Alien:IsLerk( player )
	
	if not self.liftId and not player.liftId then
		self:SetLift( player )
		self.LastLift = Shared.GetTime()
		return true
	end

	-- if the Lerk is already lifting this Gorge
	if not self.liftId then return false end
	if self.liftId == player:GetId() then 
		
		-- release
		self:ResetLift()
		self.LastLift = Shared.GetTime() 
		return  true
	end
	return false
end

function Alien:IsGorge( player )
	if not self.liftId then return false end
	-- if the Lerk is already lifting this Gorge (me)
	if self.liftId == player:GetId() then
		-- release
		self:ResetLift()
		self.LastLift = Shared.GetTime() 
		return true
	end
	return false
end

function Alien:CanLift( player )

	--not enabled
	if not Alien.kLiftEnabled then return false end

	-- don't trigger lifting to often
	if not self.LastLift and not self.LastLift + Alien.KInterval < Shared.GetTime() then return false end

	local isLifter = self:isa( Alien.kLifterClass )
	local isLifted = self:isa( Alien.kLiftedClass )

	if not isLifted and not isLifter then return false end 

	return true

end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	if Alien:CanLift() == false then useSuccessTable.UseSuccess = false return end	

	-- if this is the Gorge used by a Lerk
	if self:isa( Alien.kLiftedClass ) and player:isa( Alien.kLifterClass ) then 
		useSuccessTable.UseSuccess = Alien:IsGorge( player ) 
	
	-- if this is the Lerk used by a Gorge
	elseif self:isa( Alien.kLifterClass ) and player:isa( Alien.kLiftedClass ) then 
	
		useSuccessTable.UseSuccess = Alien:IsLerk( player ) 
	end
end

function Alien:PostUpdateMove( input, runningPrediction )

	-- if not lift then dont do anything
	if not self.liftId then return end

	-- if lifting has been disabled in midgame reset
	if not Alien.kLiftEnabled then self:ResetLift() return end

	local isLifter = self:isa( Alien.kLifterClass )
	local isLifted = self:isa( Alien.kLiftedClass )

	if not isLifted and not isLifter then self:ResetLift() return end 
			
	-- reset if lifted alien is dead or vanished
	local lift = Shared.GetEntity( self.liftId )
	if not lift or not lift:GetIsAlive() then self:ResetLift()return end
			
	-- if not lifting then reset
	if self.liftId ~= lift then self:ResetLift() return end

	if not isLifted then return end

	-- if this alien is lifted copy position from lifter
	local lifterOrigin = lift:GetOrigin()
	lifterOrigin = Vector( lifterPos + Vector( -1 , -1 , -1 ) )
	self:SetOrigin( lifterOrigin )
end

-- enabled the lifting between two aliens if there is no other lifting
function Alien:SetLift( otherAlien )

	if self.liftedId then return end

	self.liftedId = otherAlien:GetId()
	otherAlien:SetLift( self )

	self:TriggerEffects( Alien.kLifterOnSound )
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLiftedClass), Alien.kLiftedTip, Alien.kLifterTip))
end

-- reset all linking between lifter and lifted alien
function Alien:ResetLift()

	if not self.liftId then return end

	local otherlift = Shared.GetEntity( self.liftId )

	self.liftId = nil

	if otherLift then 

		otherLift:ResetLift() 
		self:TriggerEffects( Alien.kLifterOffSound )
	end
end
