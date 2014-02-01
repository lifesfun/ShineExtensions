Player.LiftOffset = Vector( 0 , 1 , 0 )
Player.LiftTolerance = 0.28
Player.LiftInterval = 0.5
Player.LiftLastUse = nil
Player.LiftID = nil

function Player:MinTime() 

	print( "hello" )
	local time = Shared.GetTime()

	if self.LiftLastUse and ( time < ( self.LiftLastUse + self.LiftInterval ) ) then self.LiftLastUse = time 

	else self.LiftLastUse = time return true end
end

function Player:LerkLift( target )

print( "test" )
	if kLiftDev then return true end
	if target.LiftID then return end
	if target:isa( "Gorge" ) then print("gorgeis") return true 

	elseif self:isa( "Gorge" ) and target:isa( "Lerkis" ) then target:isa("Lerk" ) return true end
end

function Player:GetCanBeUsed( target , useSuccessTable )
	
	useSuccessTable.UseSuccess = true 
end

function Player:OnUse( target , elapsedTime , useSuccessTable )

print( "use" )
	if not target then return end
	if not kLiftEnabled then return end

	if not self:MinTime() then return end
	if not self:LerkLift( target ) then return end

	local targetID = target:GetId()
	local selfID = self:GetId()

	--if I am used and I have my targets Id 
	if self.LiftID and self.LiftID == targetID then 

		self:ResetLift() 

	--if I am used and target has my id then reset 
	elseif target.LiftID and target.LiftID == selfID then 

		target:ResetLift() 
	else

print( target.LiftID )
		target:SetLift( selfID ) 
	end
	useSuccessTable.UseSuccess = true
end

function Player:SetLift( id )

print( "setlift" )
	self:TriggerEffects( "alien_vision_On" )
	if id then self.LiftID = id end
print( self.LiftID )

end

function Player:ResetLift()

print( "reset" )
	self:TriggerEffects( "alien_vision_off" )
	if self.LiftID then self.LiftID = nil end 
print( self.LiftID )

end

function Player:UpdateMove( deltaTime )

	if deltaTime <= 0 then return end

	if not kLiftEnabled then return end
	if not self.LiftID then return end

	local target = Shared.GetEntity( self.LiftID ) 
	if target then self:Lift( target )  

print( "lift" )
print( self.LiftID )

	else self:ResetLift() end
end

function Player:Lift( target )
	
	local attachPoint = self:GetOrigin() + self.LiftOffset	
	local targetOrigin = target:GetOrigin() 

	local distance = attachPoint - targetOrigin 
	local distanceXY = distance:GetLength()

	local min = attachPoint - self.LiftTolerance
	local max = attachPoint + self.LiftTolerance

print( targetOrigin )
	if distanceXY > min and distanceXY < max then return end
print( attachPoint )
	
	target:SetOrigin( attachPoint )
end

