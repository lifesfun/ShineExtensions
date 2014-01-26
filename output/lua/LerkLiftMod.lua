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

---lift class
--lifter class
--
function Alien:GetCanBeUsed( player , useSuccessTable )
	
	local isLifter = self:isa( Alien.kLifterClass )
	local isLiftable = self:isa( Alien.kLiftableClass )

	if isLifter or Liftable then return true end
end

function Alien:OnUse( player, elapsedTime, useSuccessTable )

	useSuccessTable.UseSuccess = self:CanUseLift( player ) 	
end

function Alien:CanUseLift( player )

	--not enabled
	if not Alien.kLiftEnabled then return false end

	-- don't trigger lifting to often
	--if self.lastLift and self.lastLift + Alien.kLiftInterval < Shared.GetTime() then return false end

	local isLifter = self:isa( Alien.kLifterClass )
	local isLiftable = self:isa( Alien.kLiftableClass )

	if not isLiftable and not isLifter then return false end 

	-- if this is the Lerk used by a Gorge
	if isLifter and player:isa( Alien.kLiftableClass ) then 

		return self:LerkCanUseLift( player ) 

	-- if this is the Gorge used by a Lerk
	elseif isLiftable and player:isa( Alien.kLifterClass ) then 

		return self:GorgeCanUseLift( player ) 
	end

	return false
end

function Alien:LerkCanUseLift( player )
	
	print("lerk")
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

	print("gorge")
	--Gorge Can Release
	if self.liftId and self.liftId == player:GetId() then

		self:ResetLift()
		self.lastLift = Shared.GetTime() 
		return true
	end
end

-- enabled the lifting between two aliens if there is no other lifting
function Alien:SetLift( otherAlien )

	if self.liftId then return end

	print("set")
	self.liftId = otherAlien:GetId()
	otherAlien:SetLift( self )

	self:TriggerEffects( Alien.kLifterOnSound )
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLiftedClass), Alien.kLiftedTip, Alien.kLifterTip))
end

-- reset all linking between lifter and lifted alien
function Alien:ResetLift()

	print( "Reset" )
	
	if not self.liftId then return end

	local otherlift = Shared.GetEntity( self.liftId )

	self.liftId = nil

	if otherLift then 

		otherLift:ResetLift() 
		self:TriggerEffects( Alien.kLifterOffSound )
	end
end
function Alien:PostUpdateMove( input, runningPrediction )

	-- if not linked then dont do anything
	if not self.liftId then return end

	--should not be linked or lifting
	if not self:ShouldLift() then return end
	print( "ShouldLift" )

	--Is the alien still lifting
	local partner = LinkedPartner()
	if not partner then self:ResetLift() return end
	print( "Partner" )

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
	local isLiftable = self:isa( Alien.kLiftableClass )

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

