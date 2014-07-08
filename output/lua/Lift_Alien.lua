Alien.LiftOffset = Vector( 0 , 1 , 0 )
Alien.LiftTolerance = 0.28
Alien.LiftTime = nil
Alien.LiftLastUse = 0
Alien.LiftID = nil

function Alien:MinTime() 

	self.LiftTime = Shared.GetTime()
	if self.LiftLastUse and ( self.LiftTime > ( self.LiftLastUse + Lift.Interval ) ) then return true end
end

function Alien:GetCanBeUsed( target , useSuccessTable )

	useSuccessTable.UseSuccess = true 
end

function Alien:OnUse( target , elapsedTime , useSuccessTable )

	if not target then return end
	if not self:MinTime() then return end
	if Lift:UseLift( target , self ) then 
		
		self.LiftLastUse = self.LiftTime
		useSuccessTable.UseSuccess = true 
	end
end

function Alien:UpdateMove( input , runningPrediction )

	if self.LiftID then Lift:KeepLifting( self , self.LiftID ) end
end
