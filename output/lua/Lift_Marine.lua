Marine.LiftOffset = Vector( 0 , 2 , 0 )
Marine.LiftTolerance = 0.16
Marine.LiftTime = nil
Marine.LiftLastUse = 0
Marine.LiftID = nil
Script.Load("lua/Lift.lua")
function Marine:MinTime() 

	self.LiftTime = Shared.GetTime()
	if self.LiftLastUse and ( self.LiftTime > ( self.LiftLastUse + Lift.Interval ) ) then return true end
end

function Marine:GetCanBeUsed( target , useSuccessTable )

	useSuccessTable.UseSuccess = true 
end

function Marine:OnUse( target , elapsedTime , useSuccessTable )

	if not target then return end
	if not self:MinTime() then return end
	if Lift:UseLift( target , self ) then 
		
		self.LiftLastUse = self.LiftTime
		useSuccessTable.UseSuccess = true 
	end
end

function Marine:UpdateMove( input , runningPrediction )

	if self.LiftID then Lift:KeepLifting( self , self.LiftID ) end
end