Lift = { 
	Enabled = true,
	Dev = false,

	OnSound = "alien_vision_on",
	OffSound = "alien_vision_off"

	DefaultOffset = Vector( 0 , 1 , 1 ),
	DefaultTolerance = 0.28 
}

--first array is lifter, second is lifted
Lift.Entity = { 
	[ "Skulk" ]  = Vector( 0 , 1 , 0 ), 
	[ "Lerk" ] = Vector( 0 , 1 , 0 ),
	[ "Gorge" ] = Vector( 0 , 1 , 0 ),	
	[ "Fade" ] = Vector( 0 , 2 , 0 ),
	[ "Onos" ] = Vector( 0 , 3 , 0 ),
	[ "Marine" ] = Vector( 0 , 2 , 0 ),
	[ "Exo" ] = Vector( 0 , 3 , 0 )
}

function Lift:UseLift( lifter , lifted ) 

	if not self.Enabled then return end

	local lifterID = lifter:GetID()
	local liftedID = lifted:GetID()

	if lifter.LiftedID and lifter.LiftedID == liftedID  then 

		self:Detach( lifter , lifted )

	elseif lifted.LiftedID and lifted.LiftedID == lifterID then  

		self:Detach( lifter , lifted )
	else 
		self:Attach( lifter , lifted )
	end
end

function Lift:IsLiftable( lifter , lifted  )

	if not self.Enabled then return end
	if self.kDev then return true end	

	if not target:GetIsAlive() then return end 
	if lifter:LiftedID then return end 

	if lifter:isa( "Gorge" ) then return true 

	elseif lifted:isa( "Gorge" ) and lifter:isa( "Lerk" ) then return true end
end

function Lift:Attach( lifter ,  lifted )

	if not self:IsLiftable( lifter , lifted ) then return false end

	lifter.TriggerEffects( Lift.OnSound )
	lifted.physicsBody:SetGravityEnabled( false ) 	

	lifter.LiftedLastVelocity = Vector( 0 , 0 , 0 )
	lifter.LiftedID = lifted:GetId() 

	lifter.Offset = self:GetOffset( lifter )
	lifted.Offset = self:GeOffset( lifted )
end

function Lift:Detach( lifter , lifted )

	lifter.TriggerEffects( Lift.OffSound )
	lifted.physicsBody:SetGravityEnabled( true ) 	
	lifter.LiftedID = nil 
	lifter.Offset = nil
	lifted.Offset = nil
end

function Lift:GetOffset( entity )

	local name = self:GetType( entity ) 
	if not name then return self.DefaultOffset end

	local offset = self.Entity[ name ] 
	if not offset then return self.DefaultOffset end

	return offset
end

function Lift:GetType( entity )
	return entity.kmap
end

function Lift:GetTolerance( entity )
	return entity.kMinimumPlayerVelocity
end

function Lift:Process( lifter , lifted , deltaTime )

	if not self.Enabled then return end
	if deltaTime <= 0 then return true end 

	local liftedOrigin = lifted:GetOrigin() 
	local lifterOrigin = lifter:GetOrigin() 
	local destination = lifted.Offset + lifter.Offset + lifterOrigin 

	local distance = destination - liftedOrigin
	local distanceXY = distance:GetLength()

	local tolerance = self:GetTolerance( lifted )  
	if not tolerance then tolerance = self.DefaultTolerance end

	local min = distanceXY - tolerance 
	local max = distanceXY + tolerance

	if distanceXY > min and distanceXY < max then return end 

	local velocity = distance / deltaTime 
	self:Lift( lifted , destination , velocity )
end

function Lift:Lift( lifted , destination , velocity )

	lifted:SetOrigin( destination ) 
	lifted:SetVelocity( velocity ) 
end


