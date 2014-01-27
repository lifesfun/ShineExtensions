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

function Alien:GetCanBeUsed( target , useSuccessTable )
	
	if not Alien.kLiftEnabled then return end
	if target:GetIsAlive() then useSuccessTable.UseSuccess = true return end
end

function Alien:MinTime() 

	local time = Shared.GetTime()

	print("Time: "..time )
	if self.LastUse and ( time > ( self.LastUse + Alien.kLiftInterval ) ) then 

		self.LastUse = Time 
	else
		self.LastUse = Time 
		return 
	end
end
	
function Alien:OnUse( target, elapsedTime, useSuccessTable )
	
	if not Alien.kLiftEnabled then return end

	self:TriggerEffects( Alien.kLiftOffSound )
	if not target then print("notarget") return end
	if not self:MinTime() then print("UnderMinTime") return end

	if not self.liftId and not target.liftId then 

		self:SetLift( target ) 
	else 
		self:ResetLift( target ) 
	end

	useSuccessTable.UseSuccess = true
	print("use")
end

function Alien:SetLift( target )
		
	self:TriggerEffects( Alien.kLiftOnSound )
	if not target then return print("notarget") end

	local id = target:GetId()	
	if id then self.liftId = id end
	print("hooked")
end

function Alien:ResetLift( target )

	self:TriggerEffects( Alien.kLiftOffSound )

	if target and target.liftId then target.liftId = nil end 
	if self.liftId then self.liftId = nil end 
	print("release")
end

function Alien:UpdateMove( deltaTime )

	if not self.liftId then return end
	if not Alien.kLiftEnabled then self:ResetLift( nil ) return end

	local target = Shared.GetEntity( self.liftId ) 
	if target and target:GetIsAlive() then 

		self:LiftTo( target , deltaTime ) 
	else 
		print("movereset")
		self:ResetLift() 
	end
	print("update")
end

function Alien:LiftTo( target , deltaTime )
	
	local attachOffset = Vector( 0 , 2 , 0 )
	local attachPoint = target:GetOrigin() + attachOffset 

	local distance = ( self:GetOrigin() - attachPoint ):GetLength()
	if distance > 1 and distance < 3 then return end

	local moveDir = GetNormalizedVector( attachPoint - self:GetOrigin() )

	local player = self:GetParent()
	player:SetOrigin( self:GetOrigin() + moveDir * distance )
	print("lift")
end

