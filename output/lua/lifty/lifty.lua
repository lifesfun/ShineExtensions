Lifty = {
	OnSound = "alien_vision_on",
	OffSound = "alien_vision_off",
	Offset = Vector( 0 , 1  , 0 ), 
	Tolerance = 0.28 ,
}

function Lifty:Liftable( lifter , lifted )

	if not lifter or not lifted then return end
	if not lifter:GetIsAlive() or not lifted:GetIsAlive() then return end
	local gamerules = GetGamerules()
	if Shared.GetCheatsEnabled() or not gamerules:GetGameStarted() then return true end
	if lifter:isa( "Lerk" ) and lifted:isa( "Gorge" ) then return true end
end

function Lifty:UseLift( user , used )

	local userID = user:GetId()
	--if used does not have a lifter ID 
	if userID and not used.LiftID and self:Liftable( used, user ) then self:Attach( used , user ) end
	--on E Detach
end

function Lifty:Attach( lifter , lifted )

	lifter:TriggerEffects( self.OnSound )
	lifter.LiftID = lifted:GetId() 
	lifter.LastLiftedOrigin = lifted:GetOrigin() 
end

function Lifty:Detach( lifted )

	lifter:TriggerEffects( self.OffSound )
	lifter.LiftID = nil
	lifter.LiftedOrigin = nil 
end

function Lifty:Lift( lifter )

	local liftedOrigin = lifter.LastLiftedOrigin

	--compute distance
	local tolerance = self.Tolerance
	local offset = self.Offset:GetLength
	
	local minTolerance = offset - tolerance
	local maxTolerance = offset + tolerance
	
	local attachPoint = lifter:GetOrigin() + offset
	local distanceXY = ( attachPoint - liftedOrigin ):GetLength()
	
	if minTolerance < distanceXY and distanceXY < maxTolerance then return end
	-- if successful get Lifted
	local liftedID = lifter.LiftID
	local lifted = Shared.GetEntity( lifterID ) 

	if self:Liftable( lifter , lifted ) then Detach( lifter ) return end

	lifted:SetOrigin( attachPoint )
	lifter:LastLiftedOrigin = attachPoint
end

