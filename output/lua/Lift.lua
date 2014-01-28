--Logic for LIft prediction
--Offset = Model/2 + AttachedModel/2 
--Grav per tick = kgrav/tick 
--Interpolation = 100
--30 20 rate per 30 = .66 per tick per interpolate
--.66 = 2 snapshots
--reset origin everysnapshot so every 66ms 
--if falling at 16/30  or .53 per tick 
--then how much tolerance should we give them for prediction 
--prediction relyies on this it thinks .53 will happen every .66ms  and provides a buffer of 100ms if we reset if the range falls outside of  .53   then = smooth?
--asuming this grave/tick = tolerance
--so every .66 ms check .53 if so then change. this probably relies on movespeed to. Velocity will be added later.
--find offset set min and max .53 or in the model  

Player.kLiftEnabled = true
Player.kLiftInterval = 0.33
Player.kLiftAll = false

kStandardTickRate = 30
Player.kLiftMin = target.kGravity/kStandardTickRate
Player.kLiftDistance = target.kGravity/kStandaredTickRate

Player.kLiftx = target.kGravity/kStandardTickRate

Player.kLifty =  target.kGravity/kStandardTickRate
--+model

Player.kLiftz = 0

Player.kLiftOnSound = "alien_vision_on"
Player.kLiftOffSound = "alien_vision_off"

local Player.Gravity = 
local Player.Min = 
local Player.Max = 
local Player.Offset = 
local Player.Lifter =   
local Player.Lifted = 

function Player:GetCanBeUsed( target , useSuccessTable )
	
	if not Player.kLiftEnabled then return end
	if target:GetIsAlive() or Player.kLiftEnabled then useSuccessTable.UseSuccess = true return end
end

function Player:OnUse( target, elapsedTime, useSuccessTable )

	if not target then return end
	local id = target:GetId()
	if not id then return end

	if not Player.kDev and not self:PubMode( target ) then return end
	if not self:MinTime() then return end
	
	if self.LiftID and LiftID == id then 

		self:ResetLift() 

	elseif target.LiftID and self.LiftID == id then 
		self:ResetLift( target ) 
	else
		self:ResetLift() 
		self:SetLift( target ) 
	end

	useSuccessTable.UseSuccess = true
end

function Player:PubMode( target )
	
	if not Player.kLiftEnabled then return end
	if not target:GetIsAlive() then return end 
	if target:LiftID then return end 

	if target:isa( "Gorge" ) then return true 

	elseif self:isa( "Gorge" ) and target:isa( "Lerk" ) then return true end
end

function Player:MinTime() 

	local time = Shared.GetTime()

	if self.LastUse and ( time < ( self.LastUse + Player.kLiftInterval ) ) then 

		self.LastUse = time 
	else
		self.LastUse = time 
		return true
	end
end

function Player:SetLift( target )

	if not target then return end
	local id = target:GetId()	
	if id then self.liftId = id end
end

function Player:ResetLift()

	self:TriggerEffects( Player.kLiftOffSound )
	if self.liftId then self.liftId = nil end 
end

function Player:UpdateMove( deltaTime )

	if not self.LiftID then return end
	if not Player.kLiftEnabled then self:ResetLift() return end

	local target = Shared.GetEntity( self.LiftID ) 

	if target then 

		local offset = self.GetOffset( self.lifted , self.lifter, self.offset )
		local min , max = self:GetPrediction( self.min , self.max , self.gravity )
		self:LiftTo( target , offset , min , max )  
	else 
		self:ResetLift() 
	end
end

function Player:LiftTo( target , offset , min , max )
	
	local offsetDistance = offset:GetLength()
	local attachPoint = target:GetOrigin() + offset	
	local distance = ( self:GetOrigin() - attachPoint ):GetLength()
	local moveDir = GetNormalizedVector( attachPoint - self:GetOrigin() )

	if distance > min + offsetDistance and distance < max + offsetDistance then return end
	self:SetOrigin( self:GetOrigin() + moveDir * distance )
end

function Player:GetOffset(  lifter , lifted , offset ) 

	--first array is lifter, second is lifted
	local class = { 
		"Skulk" = Vector( 0 , 0 , 0 ), "Lerk" = Vector( 0 , -1 , 0 ),
		"Gorge" = Vector( 0 , 0 , 0 ),	"Fade" = Vector( 0 , 2 , 0 ),
		"Onos" = Vector( 0 , 3 , 0 ), "Marine" = Vector( 0 , 2 , 0 ),
		"Exo" = Vector( 0 , 3 , 0 )
	}, { 
		"Skulk" = Vector( 0 , 0 , 0 ), "Lerk" = Vector( 0 , 0 , 0 ),
		"Gorge" = Vector( 0 , 0 , 0 ),	"Fade" = Vector( 0 , -2 , 0 ),
		"Onos" = Vector( 0 , -3 , 0 ), "Marine" = Vector( 0 , -2 , 0 ),
		"Exo" = Vector( 0 , -3 , 0 )
	},  

	return class[ 1 ][ lifter ] + class[ 2 ][ lifted ] + offset
end

function Player:GetPrediction( offsetMin , offsetMax , gravity )
		
	local tolerance = gravity / Server.kStandardRate 
	local min =  tolerance + minOffset 
	local max = tolerance + maxOffset 
	return min , max 
end


