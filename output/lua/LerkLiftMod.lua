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
	if not self:CanUseLift( player ) then return end	

	print( elapsedTime )
	--if elapsedTime < Alien.kLiftInterval then return false end

	if self:Linked( player )then self:ResetLift( player ) return end
	if not self:HaveLinks( player ) then self:SetLift( player )return end 

	useSuccessTable.UseSuccess = true
end

function Alien:SetLift( player )
	
        player.liftId = self:GetId()
	self.liftId = player:GetId()  

	print("set")

	self:TriggerEffects( Alien.kLiftOnSound )
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLifter), Alien.kLifterTip, Alien.kLiftableTip))
end

function Alien:ResetLift()

	if not self.liftId then return end
	local player = Shared.GetEntity( self.liftId ) 

	print("release")
	self.liftId = nil 
	self:TriggerEffects( Alien.kLiftOffSound )

	if player and player.liftId then player.liftId = nil end
	print("release both")
end

function Alien:PostUpdateMove( input, runningPrediction )

	if not self.liftId then return end 
	
	local player = Shared.GetEntity( self.liftId ) 

	if not player then

	print( "noplayer" ) 
	self:ResetLift() return end

	print( player ) 
	if player:isa( Alien.kLiftable ) then self:LiftTo( player ) end
end

function Alien:LiftTo( player )
	
	print( "move" )
	-- if this alien is lifted copy position from lifter
	local playerOrigin = player:GetOrigin()
	local newOrigin = Vector( playerOrigin + Vector( 1 , 1 , 1 ) )
	self:SetOrigin( newOrigin )
	print( "Lift" )
end

