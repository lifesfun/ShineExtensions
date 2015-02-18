Script.Load("lua/lifty.lua")

function Alien:GetCanBeUsed( target , useSuccessTable )

	useSuccessTable.UseSuccess = true 
end
function Alien:OnUse( target , elapsedTime , useSuccessTable )

	if not target then return end
	if not elapsedTime then return end
	if not useSuccessTable then return end
	if Lifty:UseLift( target , self ) then useSuccessTable.UseSuccess = true end
end
function Alien:UpdateMove( input , runningPrediction )

	if self.LiftID then Lifty:KeepLifting( self , self.LiftID ) end
end
