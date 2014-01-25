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
Alien.kLiftableClass = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftableTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLifterOnSound = "alien_vision_on"
Alien.kLifterOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( player , useSuccessTable )

	if self:GetIsAlive() then useSuccessTable.UseSuccess = true end
end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	useSuccessTable.UseSuccess = self:CanUseLift( player ) 	
end

function Alien:CanUseLift( player )

	--not enabled
	if not Alien.kLiftEnabled then return false end

	-- don't trigger lifting to often
	if self.lastLift and self.lastLift + Alien.KInterval > Shared.GetTime() then return false end

	local isLifter = self:isa( Alien.kLifterClass )
	local isLiftable = self:isa( Alien.kLiftableClass )

	if not isLiftable or not isLifter then return false end 

	-- if this is the Lerk used by a Gorge
	if isLiftable and player:isa( Alien.kLiftableClass ) then 

		return self:LerkCanUseLift( player ) 

	-- if this is the Gorge used by a Lerk
	elseif isLifter and player:isa( Alien.kLifterClass ) then 

		return self:GorgeCanUseLift( player ) 
	end
end

function Alien:LerkCanUseLift( player )
	
	--Can lift
	if not self.liftId and not player.liftId then

		self:SetLift( player )
		self.lastLift = Shared.GetTime()
		return true

	-- if the Lerk is already lifting this Gorge
	elseif self.liftId and self.liftId ==  player:GetId() then 
		
		self:ResetLift()
		self.lastLift = Shared.GetTime() 
		return  true
	end
end

function Alien:GorgeCanUseLift( player )

	--Gorge Can Release
	if self.liftId and self.liftId == player:GetId() then

		self:ResetLift()
		self.lastLift = Shared.GetTime() 
		return true
	end
end

function Alien:PostUpdateMove( input, runningPrediction )

	-- if not linked then dont do anything
	if not self.liftId then return end

	--should not be linked or lifting
	if not self:ShouldLift() then return end

	--Is the alien still lifting
	local partner = LinkedPartner()
	if not partner then self:ResetLift() return end

	if self:isa( Alien.kLiftableClass ) then self:Lift() end
end

function Alien:ShouldLift()

	-- if lifting has been disabled in midgame reset
	if not Alien.kLiftEnabled then self:ResetLift() return end

	--if not a liftable class then reset
	if self:LiftClass() then return self:ResetLift()  end 	
end

function Alien:LiftClass()

	local isLifter = self:isa( Alien.kLifterClass )
	local isLiftable = self:isa( Alien.kLiftablClass )

	if not isLiftable and not isLifter then return false end 
end

function Alien:LinkedPartner()

	local partner = Shared.GetEntity( self.liftId )
	if partner and partner:GetIsAlive() then return partner end   
end

function Alien:Lift()

	-- if this alien is lifted copy position from lifter
	local lifterOrigin = lift:GetOrigin()
	lifterOrigin = Vector( lifterPos + Vector( -1 , -1 , -1 ) )
	self:SetOrigin( lifterOrigin )
	print( "Lift" )
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
