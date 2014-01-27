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
	local LerkLiftCommand = self:BindCommand( "lift" , "lift" , Lift )
	LerkLiftCommand:AddParam{ Type = "boolean" }
	LerkLiftCommand:Help( "Type lift true/false to enable or disable" )

	local function SetLift( Client, x , y , z , distance )

		Alien.kLiftx = x
		Alien.kLifty = y
		Alien.kLiftz = z
		Alien.kLiftDistance = distance

		self:Notify( nil , "x %s " , true ,  Alien.kLiftx  )
		self:Notify( nil , "y %s" , true ,  Alien.kLifty    )
		self:Notify( nil , "z %s" , true ,  Alien.kLiftz  )
		self:Notify( nil , "D %s " , true ,  Alien.kLiftDistance )
	end
	local LiftSetCommand = self:BindCommand( "setlift" , "setlift" , SetLift )
	LiftSetCommand:AddParam{ Type = "number" }
	LiftSetCommand:AddParam{ Type = "number" }
	LiftSetCommand:AddParam{ Type = "number" }
	LiftSetCommand:AddParam{ Type = "number" }
	LiftSetCommand:Help( "Type lift x y z distance to enable or disable" )

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	Alien.kLiftEnabled = false 
end

Shine:RegisterExtension( "lerklift" , Plugin )
