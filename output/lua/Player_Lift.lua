Script.Load( "lua/Lift.lua")

function Player:MinTime() 

	print( "hello" )
	local time = Shared.GetTime()

	if self.LiftLastUse and ( time < ( self.LiftLastUse + Lift.Interval ) ) then self.LiftLastUse = time 

	else self.LiftLastUse = time return true end
end


--Ns2 hooks
function Player:GetCanBeUsed( target , useSuccessTable )
	
	 useSuccessTable.UseSuccess = true 
end

function Player:OnUse( target , elapsedTime , useSuccessTable )
print( "use" )

	if not target then return end
	--not sure about this
	if Lift:Mode( self , target )
	if not self.LiftEnabled then return end
	if not self:MinTime() then return end

	self.LiftOffset = Lift:GetOffset( target.kMapName , self.kMapName )
	self.LiftTolerance = Lift:GetPrediction( target.kGravity )
	
	local selfID = self:GetId()
	local targetID = target:GetId()

	--if I am used and I have my targets Id 
	if self.LiftID and self.LiftID == targetID then 

		self:ResetLift() 

	--if I am used and target has my id then reset 
	elseif target.LiftID and target.LiftID == selfID then 

		target:ResetLift() 
	else
		target:SetLift( selfID ) 
	end
	useSuccessTable.UseSuccess = true
end

function Player:UpdateMove( deltaTime )

	--how to check global
	if not self.LiftEnabled then return end
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

