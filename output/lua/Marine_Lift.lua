Marine.LiftOffset = Vector( 0 , 1 , 0 )
Marine.LiftTolerance = 0.28

Marine.LiftInterval = 0.33

Marine.LiftLastUse = nil
Marine.LiftID = nil

function Marine:MinTime() 

	local time = Shared.GetTime()

	if self.LiftLastUse and ( time < ( self.LiftLastUse + self.LiftInterval ) ) then self.LiftLastUse = time 

	else self.LiftLastUse = time return true end
end

function Marine:GetCanBeUsed( target , useSuccessTable )
	useSuccessTable.UseSuccess = true 
end

function Marine:OnUse( target , elapsedTime , useSuccessTable )

	if not target then return end
	
	if not kLiftEnabled then return end
	if not self:MinTime() then return end

	local targetID = target:GetId()
	local selfID = self:GetId()

	--if I am used and I have my targets Id 
	if self.LiftID and self.LiftID == targetID then self:ResetLift() 

	--if I am used and target has my id then reset 
	elseif target.LiftID and target.LiftID == selfID then target:ResetLift() 
	
	else self:ResetLift() 
		self:SetLift( targetID ) 
	end
	useSuccessTable.UseSuccess = true
end

function Marine:LerkLift( target )

	if Shared.GetCheatsEnabled() or kLiftDev or not self:GetGameStarted() then return true end
	
	if not self:GetIsAlive() then return end 
	if target.LiftedID then return end 
	
	if target:isa( "Gorge" ) then return true 
	elseif self:isa( "Gorge" ) and target:isa( "Lerk" ) then return true end
end

function Marine:SetLift( id )

	if not self:LerkLift( target ) then return end
	
	self:TriggerEffects( "Marine_vision_on" )
	if id then self.LiftID = id end
end

function Marine:ResetLift()

	self:TriggerEffects( "Marine_vision_off" )
	if self.LiftID then self.LiftID = nil end 
end

function Marine:UpdateMove( input , runningPrediction )

	if not self.LiftID then return end
	if not self:GetIsAlive() then self:ResetLift() return end 
	if not kLiftEnabled then self:ResetLift() return end
	
	local target = Shared.GetEntity( self.LiftID ) 
	if not target then self:ResetLift()
	
	else target:Lift( self )  end
end

function Marine:Lift( target )
	
	local attachPoint = self:GetOrigin() + self.LiftOffset	
	local targetOrigin = target:GetOrigin() 
	local offset = self.LiftOffset:GetLength()

	local distance = attachPoint - targetOrigin 
	local distanceXY = distance:GetLength()

	local min = offset - self.LiftTolerance
	local max = offset + self.LiftTolerance

	if distanceXY > min and distanceXY < max then return end
	target:SetOrigin( attachPoint )
end

