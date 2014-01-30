Lift = { 

	kLiftEnabled = true,
	kLiftDev = false,

	kLiftInterval = 0.33, 
	kLiftStandardTickRate = 30,

	kLiftOffset = 30,
	kLiftTolerance = 30,

	kLiftOnSound = "alien_vision_on",
	kLiftOffSound = "alien_vision_off"
}

--first array is lifter, second is lifted
Lift.Class = { 
		[ "Skulk" ] = Vector( 0 , 1 , 0 ), [ "Lerk" ] = Vector( 0 , 1 , 0 ),
		[ "Gorge" ] = Vector( 0 , 1 , 0 ),[ "Fade" ] = Vector( 0 , 3 , 0 ),
		[ "Onos" ] = Vector( 0 , 4 , 0 ), [ "Marine" ] = Vector( 0 , 3 , 0 ),
		[ "Exo" ] = Vector( 0 , 4 , 0 )
}, { 
		[ "Skulk" ] = Vector( 0 , 0 , 0 ), [ "Lerk" ] = Vector( 0 , 0 , 0 ),
		[ "Gorge" ] = Vector( 0 , 0 , 0 ),[ "Fade" ] = Vector( 0 , 1 , 0 ),
		[ "Onos" ] = Vector( 0 , 1 , 0 ), [ "Marine" ] = Vector( 0 , 1 , 0 ),
		[ "Exo" ] = Vector( 0 , 1 , 0 )
}  

function Lift:Mode( self , target )
	
	if not self.Enabled then return end
	if not target:GetIsAlive() then return end 
	if target:LiftID then return end 

	if target:isa( "Gorge" ) then return true 

	elseif self:isa( "Gorge" ) and target:isa( "Lerk" ) then return true end
end

function Lift:GetOffset( lifterName , liftedName , override ) 
	local lifter = self.Class[ 1 ]
	local lifted = self.Class[ 2 ]

	return lifer[ lifterName ] + lifted[ liftedName ] + override 
end

function Lift:GetPrediction( tolerance , gravity )
		
	local tolerance = gravity / self.StandardTickRate 
	local tolerance = tolerance + max
	return tolerance 
end



