Lift = {
	Interval = 0.5,
	OnSound = "alien_vision_on",
	OffSound = "alien_vision_off",
	Offset = Vector( 0 , 2.8 , 0 ),
	Tolerance = 0.28 
}

function Lift:All()

	return true
	local gamerules = GetGamerules()
	if Shared.GetCheatsEnabled() or not gamerules:GetGameStarted() then return true end
end

function Lift:Liftable( lifter , lifted )

	if not self.Enabled then return end
	if self:All() then return true end

	if lifted.LiftedID or lifted.LifterID then return end 
	if not lifter:GetIsAlive() or not lifted:GetIsAlive() then return end
	
	if lifted:isa( "Gorge" ) and lifter:isa( "Lerk" ) then return true end
end

function Lift:UseLift( user , used )

	local userID = user:GetId()
	local usedID = used:GetId()
	--if I am used and I have my targets Id 
	if used.LiftID and used.LiftID == userID then self:Detach( used ) return true

	--if I am used and target has my id then reset 
	elseif user.LiftID and user.LiftID == usedID then self:Detach( user) return true
	
	elseif self:Liftable( user , used ) then self:Attach( used , userID ) return true end
end

function Lift:Attach( lifted , lifterID)

	lifted:TriggerEffects( self.OnSound )
	if lifterID then lifted.LiftID = lifterID end
end

function Lift:Detach( lifted )

	lifted:TriggerEffects( self.OffSound )
	if lifted.LiftID then lifted.LiftID = nil end
end

function Lift:KeepLifting( lifted , lifterID )

	if not self.Enabled then self:Detach( lifted) return end
	
	local lifter = Shared.GetEntity( lifterID ) 
	if not lifter then self:Detach( lifted ) return end

	if self:All() then self:Lift( lifter , lifted ) 
	
	elseif lifter:GetIsAlive() and lifted:GetIsAlive() then self:Lift( lifter, lifted ) 
	
	else self:Detach( lifter ) end
end

function Lift:Lift( lifter , lifted )

	local tolerance = lifter.LiftTolerance 
	if not tolerance then tolerance = self.Tolerance end
	
	local offset = lifter.LiftOffset
	if not offset then offset = self.Offset end
	
	local offsetXY = offset:GetLength() 
	local minTolerance = offsetXY - tolerance
	local maxTolerance = offsetXY + tolerance
	
	local attachPoint = lifter:GetOrigin()  + offset
	local liftedOrigin = lifted:GetOrigin()
	
	local distanceXY = ( attachPoint - liftedOrigin ):GetLength()
	if minTolerance < distanceXY and distanceXY < maxTolerance then return end
	
   -- local moveDir = GetNormalizedVector( attachPoint - liftedOrigin)

	lifted:SetOrigin( attachPoint )
--	lifted:SetOrigin( liftedOrigin + moveDir * distanceXY )
end

