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

Alien.kLifter = "Lerk"
Alien.kLiftable = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftableTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLiftOnSound = "alien_vision_on"
Alien.kLiftOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( player , useSuccessTable )

	if not Alien.kEnabled then return end 
	if not self:CanUseLift() then return end

	if self:HaveLinks() and not self:Linked() then return 

	elseif self:HaveLinks() then return end 

	--if linked together or both do not have links then alien can use
	useSuccessTable.UseSuccess = true 
end

function Alien:CanUseLift( player )

	if self:isa( Alien.kLifter ) and player:isa( Alien.kLiftable ) then return true end
	if player:isa( Alien.kLifter ) and self:isa( Alien.kLiftable ) then return true end 	
	return false
end

function Alien:HaveLinks( player ) 

	if self.liftId or player.liftId then return true end  
	return false
end

function Alien:Linked( player ) 

	local playerId = player:GetId()
	local selfId = player:GetId()

	if playerId and selfId and self.liftId == playerId or player.liftId == selfId then return true end 
	return false
end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	if elapsedTime < Alien.kLiftInterval then return end

	if not self:Havelinks( player ) and self:isa( Alien.kLiftable ) then self:SetLift( player ) 

	elseif self:Linked( player ) then self:ResetLift( player ) end

	useSuccessTable.UseSuccess = true
end

function Alien:SetLift( player )
	
        player.liftId = self:GetId()
	self.liftId = player:GetId()  

	if not player.liftId or not self.liftId then self:Resetlift() return end
	print("lift")

	self:TriggerEffects( Alien.kLiftOnSound )
	self:AddTooltip(ConditionalValue(self:isa(Alien.kLiftedClass), Alien.kLiftedTip, Alien.kLifterTip))
end

-- reset all linking between lifter and lifted alien
function Alien:ResetLift()

	if not self.liftId then return end
	local player = Shared.GetEntity( self.liftId ) 

	print("release")
	self.liftId = nil 
	self:TriggerEffects( Alien.kLiftOffSound )

	if player and player.liftId then player.liftId = nil end
	print("reset")


end

function Alien:PostUpdateMove( input, runningPrediction )

	if not Alien.Enabled then self:ResetLift() return end 

	local player = self.liftId 
	if not player then self:ResetLift() return end

	if self:isa( Alien.kLiftableClass ) then self:LiftTo( player ) end
end

function Alien:LiftTo( player )
	
	-- if this alien is lifted copy position from lifter
	local playerOrigin = player:GetOrigin()
	newOrigin = Vector( playerOrigin + Vector( 1 , 1 , 1 ) )
	self:SetOrigin( newOrigin )
	print( "Lift" )
end

