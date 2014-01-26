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

Alien.kLiftInterval = 0.33

Alien.kLifter = "Lerk"
Alien.kLiftable = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftableTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLiftOnSound = "alien_vision_on"
Alien.kLiftOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( player , useSuccessTable )

	useSuccessTable.UseSuccess = true 
end

function Alien:CanUseLift( player )

	if self:isa( Alien.kLifter ) and player:isa( Alien.kLiftable ) then print("lerk") return true end
	if player:isa( Alien.kLifter ) and self:isa( Alien.kLiftable ) then  print("gorge") return true end 	
	return false
end

function Alien:HaveLinks( player ) 

	if self.liftId or player.liftId then
	return true end  
	print("nolinks")
	return false
end

function Alien:Linked( player ) 

	local playerId = player:GetId()
	local selfId = self:GetId()

	if playerId and selfId then 
		if self.liftId == playerId or player.liftId == selfId then
		print("linked")
		return true end 
	end
	return false
end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	print("use")
--	if not self:CanUseLift( player ) then return end	

	print( elapsedTime )
	--if elapsedTime < Alien.kLiftInterval then return false end

	if self:HaveLinks( player ) then self:ResetLift( player ) return end
	if not self:HaveLinks( player ) then self:SetLift( player )return end 

	useSuccessTable.UseSuccess = true
end

function Alien:SetLift( player )
	
	self.liftId = player:GetId()  
	self:TriggerEffects( Alien.kLiftOnSound )
	print("set")
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLifter), Alien.kLifterTip, Alien.kLiftableTip))
end

function Alien:ResetLift( player )

	if self.liftId then self.liftId = nil end 
	if player.liftId then player.liftId = nil end
	self:TriggerEffects( Alien.kLiftOffSound )
	print("release")
end

function Alien:PostUpdateMove( input, runningPrediction )

	if not self.liftId then return end

	local player = Shared.GetEntity( self.liftId ) 
	if not player or not player:GetIsAlive() then self:ResetLift() return end

	self:LiftTo( player ) 
end

function Alien:LiftTo( player )
	
	-- if this alien is lifted copy position from lifter
	local O = player:GetOrigin()
	local new = O + Vector( 0 , 3 , 0 )
	self:SetCoords( new )
end

