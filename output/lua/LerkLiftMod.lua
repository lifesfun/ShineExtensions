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

function Alien:GetCanBeUsed( target , useSuccessTable )
	
	if not target:GetIsAlive() then return end
	useSuccessTable.UseSuccess = true 
end

function Alien:CanUseLift( target )

	if self:isa( Alien.kLifter ) and target:isa( Alien.kLiftable ) then print("lerk") return true end
	if target:isa( Alien.kLifter ) and self:isa( Alien.kLiftable ) then  print("gorge") return true end 	
	return false
end

function Alien:OnUse( target, elapsedTime, useSuccessTable )

	--if not self:CanUseLift( target ) then return end	

	if not self.Time then self.Time = Shared.GetTime() end 
	if Shared.GetTime() - self.Time < Alien.kLiftInterval then return end

	print("use")
	if not target and target:GetIsAlive() then self:ResetLift( target ) return end 

	useSuccessTable.UseSuccess = true
	self.Time = Shared.GetTime()

	if not self.liftId and not target.liftId then self:SetLift( target )return end 
	self:ResetLift( target )
end

function Alien:SetLift( target )
	
	self:TriggerEffects( Alien.kLiftOnSound )
	self.liftId = target:GetId()  

	--self:SetPhysicsType( CollisionObject.Kinematic ) 
	print("hooked")
	--self:AddTooltip(ConditionalValue(self:isa(Alien.kLifter), Alien.kLifterTip, Alien.kLiftableTip))
end

function Alien:ResetLift( target )

	self:TriggerEffects( Alien.kLiftOffSound )
	if self.liftId then self.liftId = nil end 
	if target.liftId then target.liftId = nil end 
	--self:SetPhysicsType( CollisionObject.Dynamic ) 
	print("release")
end

function Alien:UpdateMove( deltaTime )

	if not self.liftId then return end

	local target = Shared.GetEntity( self.liftId ) 
	if not target or not target:GetIsAlive() then self:ResetLift() return end

	self:LiftTo( target , deltaTime ) 
	print("update")
end

function Alien:LiftTo( target , deltaTime )
	
	-- if this alien is lifted copy position from lifter
	
	local AttachOffset = Vector( 0 , 1 , 1 )
	local AttachPoint = target:GetOrigin() + AttachOffset 

	local Distance = ( self:GetOrigin() - AttachPoint ):GetLength()
	if Distance < 2 then return end

	--local MaxDistance = deltaTime * 15  
	--if Distance < MaxDistance then self:ResetLift() return end

	local MoveDir = GetNormalizedVector( AttachPoint - self:GetOrigin() )

	if self:GetPhysicsType() ~= "Kinematic" then self:SetPhysicsType( CollisionObject.Kinematic ) end 

	self:SetOrigin( self:GetOrigin() + MoveDir * Distance )
	print("lift")
	
end

