--Extended the original to be used with shine. See LerkLiftMod.lua for authors information. Thanks to the author Hackepeter 

local Shine = Shine

local Plugin = {} 

Plugin.HasConfig = false 

function Plugin:Initialise()
	
	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "LiftMod" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:CreateCommands()

	local function Lift( Client, Enable)

		Alien.kLiftEnabled = Enable 
		self:Notify( nil , "Lift is %s" , true , Alien.kLiftEnabled  )	
	end
	local LiftCommand = self:BindCommand( "lift" , "lift" , Lift )
	LiftCommand:AddParam{ Type = "boolean" }
	LiftCommand:Help( "Type lift true/false to enable or disable" )

	local function LiftAll( Client, Enable)

		Alien.kAll = Enable 
		self:Notify( nil , "Lift is %s" , true , Alien.kAll)	
	end
	local LiftAllCommand = self:BindCommand( "liftall" , "liftall" , LiftAll )
	LiftAllCommand:AddParam{ Type = "boolean" }
	LiftAllCommand:Help( "Type lift true/false to enable or disable" )


	local function SetLiftOffset( Client, x , y , z  )

		Alien.kLiftx = x
		Alien.kLifty = y
		Alien.kLiftz = z

		self:Notify( nil , "x %s " , true ,  Alien.kLiftx  )
		self:Notify( nil , "y %s" , true ,  Alien.kLifty    )
		self:Notify( nil , "z %s" , true ,  Alien.kLiftz  )
	end
	local LiftSetOffsetCommand = self:BindCommand( "setoffset" , "setoffset" , SetLiftOffset )
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:Help( "Type lift x y z distance to enable or disable" )

	local function SetLift( Client, min , distance )

		Alien.kLiftMin = min
		Alien.kLiftDistance = distance

		self:Notify( nil , "M %s " , true ,  Alien.kLiftMin)
		self:Notify( nil , "D %s " , true ,  Alien.kLiftDistance )
	end
	local SetLiftCommand = self:BindCommand( "setlift" , "setlift" , SetLift )
	SetLiftCommand:AddParam{ Type = "number" }
	SetLiftCommand:AddParam{ Type = "number" }
	SetLiftCommand:Help( "Type lift x y z distance to enable or disable" )


end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	Alien.kLiftEnabled = false 
end

Shine:RegisterExtension( "lerklift" , Plugin )
