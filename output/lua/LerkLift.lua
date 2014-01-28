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
Alien.kLiftInterval = 0.5

Alien.kLiftMin = 0.99
Alien.kLiftDistance = 0.33
Alien.kLiftx = 0
Alien.kLifty = 0.95
Alien.kLiftz = 0

Alien.kLiftOnSound = "alien_vision_on"
Alien.kLiftOffSound = "alien_vision_off"

function Alien:GetCanBeUsed( target , useSuccessTable )
	
	if not Alien.kLiftEnabled then return end
	if target:GetIsAlive() then useSuccessTable.UseSuccess = true return end
end

function Alien:MinTime() 

	local time = Shared.GetTime()

	if self.LastUse and ( time < ( self.LastUse + Alien.kLiftInterval ) ) then 

		self.LastUse = time 
	else
		self.LastUse = time 
		return true
	end
end
	
function Alien:OnUse( target, elapsedTime, useSuccessTable )
	
	if not Alien.kLiftEnabled then return end

	if not target then return end
	if not self:MinTime() then return end


	self:TriggerEffects( Alien.kLiftOffSound )

	if not self.liftId and not target.liftId then 

		self:SetLift( target ) 
	else 
		self:ResetLift( target ) 
	end

	useSuccessTable.UseSuccess = true
end

function Alien:SetLift( target )
		
	if not self:isa( "Gorge" ) or not target:isa( "Lerk" ) then return end
	self:TriggerEffects( Alien.kLiftOnSound )
	if not target then return print("notarget") end

	local id = target:GetId()	
	if id then self.liftId = id end
end

function Alien:ResetLift( target )

	self:TriggerEffects( Alien.kLiftOffSound )

	if target and target.liftId then target.liftId = nil end 
	if self.liftId then self.liftId = nil end 
end

function Alien:UpdateMove( deltaTime )

	if not self.liftId then return end
	if not Alien.kLiftEnabled then self:ResetLift( nil ) return end

	local target = Shared.GetEntity( self.liftId ) 
	if target and target:GetIsAlive() then 

		self:LiftTo( target , deltaTime ) 
	else 
		self:ResetLift() 
	end
end

function Alien:LiftTo( target , deltaTime )
	
	local attachOffset = Vector( Alien.kLiftx , Alien.kLifty  , Alien.kLiftz )
	local attachPoint = target:GetOrigin() + attachOffset 

	local distance = ( self:GetOrigin() - attachPoint ):GetLength()
	if distance > Alien.kLiftMin and distance < Alien.kLiftDistance then return end

	local moveDir = GetNormalizedVector( attachPoint - self:GetOrigin() )

	self:SetOrigin( self:GetOrigin() + moveDir * distance )
end

