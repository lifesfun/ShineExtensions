--Extended the original to be used with shine. See LerkLiftMod.lua for authors information. Thanks to the author Hackepeter 

local Shine = Shine

local Plugin = {} 
Plugin.Version "0.9"

Plugin.HasConfig = true 
Plugin.ConfigName = "Lift.json"

Plugin.DefaultConfig = {

	Default = true,
	DevMode = false

	Clogs = 20,

	Hydras = 5,
	HydraCost = 1,

	Babblers= 5,
	BabblerPerEgg = 5,
	BabblerCost = 0
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()
	Clogs 

	kH 
	kHydraCost

	kNumBabblerEggsPerGorge =  BabblereggsPerGorge
	kNumBabblersPerEgg = BabblerPerEgg
	kBabblerCost = BabblerCost

	Player.kLiftEnabled = self.Config.Default 
	DevMode = self.Config.Dev

	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "LiftMod" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:CreateCommands()

	local function Lift( Client, Enable)

		Player.kLiftEnabled = Enable 
		self:Notify( nil , "Lift is %s" , true , Player.kLiftEnabled  )	
	end
	local LiftCommand = self:BindCommand( "lift" , "lift" , Lift )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftCommand:Help( "Type lift true/false to enable or disable" )

	local function LiftDev( Client, Enable)

		Player.kLift = Enable 
		self:Notify( nil , "LiftDev is %s" , true , Player.kLiftDev )	
	end
	local LiftDevCommand = self:BindCommand( "liftdev" , "liftdev" , LiftDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftDevCommand:Help( "Type lift true/false to enable or disable" )


	local function SetLiftOffset( Client, x , y , z  )

		Player.kLiftx = x
		Player.kLifty = y
		Player.kLiftz = z

		self:Notify( nil , "x %s " , true ,  Player.kLiftx  )
		self:Notify( nil , "y %s" , true ,  Player.kLifty    )
		self:Notify( nil , "z %s" , true ,  Player.kLiftz  )
	end
	local LiftSetOffsetCommand = self:BindCommand( "setoffset" , "setoffset" , SetLiftOffset )
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:AddParam{ Type = "number" }
	LiftSetOffsetCommand:Help( "Type lift x y z distance to enable or disable" )

	local function SetLift( Client, min , distance )

		Player.kLiftMin = min
		Player.kLiftDistance = distance

		self:Notify( nil , "M %s " , true ,  Player.kLiftMin)
		self:Notify( nil , "D %s " , true ,  Player.kLiftDistance )
	end
	local SetLiftCommand = self:BindCommand( "setlift" , "setlift" , SetLift )
	SetLiftCommand:AddParam{ Type = "number" }
	SetLiftCommand:AddParam{ Type = "number" }
	SetLiftCommand:Help( "Type lift x y z distance to enable or disable" )


end

function Plugin:Cleanup()

	Player.kLiftEnabled = false 
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
