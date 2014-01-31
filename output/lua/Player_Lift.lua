kLiftEnabled = nil
kLiftDev = nil

local Player = { 

	LiftOffset = Vector( 0 , 1 , 0 ),
	LiftTolerance = 0.28,
	LiftLastUse = nil,
	LiftID = nil
}

function Player:MinTime() 

	print( "hello" )
	local time = Shared.GetTime()

	if self.LiftLastUse and ( time < ( self.LiftLastUse + Lift.Interval ) ) then self.LiftLastUse = time 

	else self.LiftLastUse = time return true end
end

function Player:LerkLift( target )

print( "test" )
	if kLiftDev then return true end
	if target.LiftID then return end
	if target:isa( "Gorge" ) then return true 

	elseif self:isa( "Gorge" ) and target:isa( "Lerk" ) then 
	return true end
end

function Player:GetCanBeUsed( target , useSuccessTable )
	
	if kLiftEnabled then useSuccessTable.UseSuccess = true end
end

function Player:OnUse( target , elapsedTime , useSuccessTable )

print( "use" )
	if not target then return end
	if not kLiftEnabled then return end
	if not self:LerkLift( target ) then return end

	if not self:MinTime() then return end
	
	local selfID = self:GetId()
	local targetID = target:GetId()

	--if I am used and I have my targets Id 
	if self.LiftID and self.LiftID == targetID then 

		self:ResetLift() 

	--if I am used and target has my id then reset 
	elseif target.LiftID and target.LiftID == selfID then 

		target:ResetLift() 
	else
		target:ResetLift() 
		target:SetLift( selfID ) 
	end
	useSuccessTable.UseSuccess = true
end

function Player:UpdateMove( deltaTime )

	if not kLiftEnabled then return end
print( "update" )
	if not self.LiftID then return end

	local target = Shared.GetEntity( self.LiftID ) 
	if target then self:Lift( target )  

print( "lift" )
	else self:ResetLift() end
end

---use functions 
function Player:SetLift( id )

print( "set" )
	self:TriggerEffects( Lift.OnSound )
	if id then self.LiftID = id end
end

function Player:ResetLift()

print( "reset" )
	self:TriggerEffects( Lift.OffSound )
	if self.LiftID then self.LiftID = nil end 
end

---Lift function 
function Player:Lift( target )
	
	local attachPoint = self:GetOrigin() + self.LiftOffset	
	local targetOrigin = target:GetOrigin() 

	local distance = ( attachPoint - targetOrigin ):GetLength()
	local min = attachPoint - self.LiftTolerance
	local max = attachPoint + self.LiftTolerance

	if distance > min and distance < max then return end
	
	local moveDir = GetNormalizedVector( attachPoint - targetOrigin )
	target:SetOrigin( targetOrigin + moveDir * distance )
end

