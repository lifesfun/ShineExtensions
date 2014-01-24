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
Script.Load( "lua/Player.lua" )
Alien.kLiftEnabled = true

Alien.kLiftInterval = 1

Alien.kLifterClass = "Lerk"
Alien.kLiftedClass = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftedTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLifterOnSound = "alien_vision_on"
Alien.kLifterOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( player , useSuccessTable )

    if self:GetIsAlive() then return true end
	
    return Player.GetCanBeUsed( self )
end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	if not Alien.kLiftEnabled then return end--and -- don't trigger lifting to often
	--(self.timeOfLastLift == nil or (Shared.GetTime() - self.timeOfLastLift) > Alien.kLiftInterval) then
		-- if this is the Gorge used by a Lerk
	if self:isa( Alien.kLiftedClass ) and player:isa( Alien.kLifterClass ) then
		
		-- if the Lerk is not yet lifting any Gorge
		if player.liftingToId == nil then
			
			-- lift the gorge
			self:SetLiftingTo( player )
			--self.timeOfLastLift = Shared.GetTime()
				
			return true

		-- if the Lerk is already lifting this Gorge (me)
		elseif player.liftingToId == self:GetId() then
			
			-- release
			self:ResetLifting()
			--self.timeOfLastLift = Shared.GetTime()
				
			return true
		end
		
	-- if this is the Lerk used by a Gorge
	elseif self:isa( Alien.kLifterClass ) and player:isa( Alien.kLiftedClass ) then
		
		-- if the Lerk is already lifting this Gorge
		if self.liftingToId == player:GetId() then
			
			-- release
			self:ResetLifting()
			--self.timeOfLastLift = Shared.GetTime()
				
			return true
		end
	end
	
--	return Player.OnUse(  player, elapsedTime, useSuccessTable )
end

function Alien:PostUpdateMove( input, runningPrediction )

	-- if not lifted then dont do anything
	if self.liftingToId == nil then return end

	-- if lifting has been disabled in midgame reset
	if not Alien.kLiftEnabled then self:ResetLifting() return end
		
	local isLifter = self:isa( Alien.kLifterClass )
	local isLifted = self:isa( Alien.kLiftedClass )

	if not isLifter and not isLifted then return end
				
	-- if not lifting then reset
	if self.liftingToId == nil then self:ResetLifting() return end

	local liftingTo = nil
	liftingTo = Shared.GetEntity( self.liftingToId )
				
	-- reset if lifted alien is dead or vanished
	if liftingTo == nil or not liftingTo:GetIsAlive() then return end
					
	-- if this alien is lifted copy position from lifter
	if not isLifted then return end

	local lifterPos = liftingTo:GetOrigin()
	liftedPos = Vector( lifterPos + Vector( 0 , 1 , 0 ))
	self:SetOrigin( liftedPos )
end

-- enabled the lifting between two aliens if there is no other lifting
function Alien:SetLiftingTo( otherAlien )

	if self.liftingToId ~= nil then return end

	self.liftingToId = otherAlien:GetId()
	self:TriggerEffects( Alien.kLifterOnSound )
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLiftedClass), Alien.kLiftedTip, Alien.kLifterTip))
	otherAlien:SetLiftingTo( self )
end

-- reset all linking between lifter and lifted alien
function Alien:ResetLifting()

	if self.liftingToId == nil then return end

	local liftingTo = Shared.GetEntity( self.liftingToId )
	self.liftingToId = nil

	if liftingTo ~= nil then liftingTo:ResetLifting() end
		
	self:TriggerEffects( Alien.kLifterOffSound )
end
