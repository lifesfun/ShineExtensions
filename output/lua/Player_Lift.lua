Script.Load( "lua/Lift.lua")

Player.LiftInterval = 0.5 
Player.LiftLastUse = nil
Player.LiftedID = nil

function Player:MinTime() 

	local time = Shared.GetTime()

	if self.LiftLastUse and ( time < ( self.LiftLastUse + self.Interval ) ) then self.LiftLastUse = time 

	else self.LiftLastUse = time return true end
end

function Player:GetCanBeUsed( target , useSuccessTable )
	
	 useSuccessTable.UseSuccess = true
end

function Player:OnUse( target , elapsedTime , useSuccessTable )

	if not target then return end
	if not self:MinTime() then return end

	Lift:UseLift( lifter , lifted )
	useSuccessTable.UseSuccess = true
end

function Player:UpdateMove( deltaTime )

	if not self.LiftedID then return end 

	local lifted = Shared.GetEntity( self.LiftedID ) 
	if lifted then Lift:Proccess( self , lifted , deltaTime )  
	else Lift:Detach( self , lifted ) end
end
