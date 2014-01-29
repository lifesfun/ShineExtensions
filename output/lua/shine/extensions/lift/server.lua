--A mod that provides Lift functions and more!

local Shine = Shine

local Lift = Lift

local kEnabled = Lift.kLiftEnabled 
local kDev = Lift.kLiftDev 
local kOffset = Lift.kLiftOffset
local kTolerance = Lift.kLiftTolerance
local Vector = Vector


local Plugin = {} 
Plugin.Version "1.0"

Plugin.HasConfig = true 
Plugin.ConfigName = "Lift.json"

Plugin.DefaultConfig = {

	Default = true,
	DevMode = false,
	Tolerance = 0.53,
	Offset = Vector( 0 , 0 , 0 )
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()

	kEnabled = self.Config.Default 
	kDev = self.Config.kDev
	kOffset = self.Config.kOffset
	kTolerance = self.Config.kTolerance

	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "LiftBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

		self:Notify( Client , "The Lift mod is enabled!" )
		self:Notify( Client , "Use e to lift up a gorge as a lerk." )
		self:Notify( Client , "Use e to lift up any living player as a gorge" )
end

function Plugin:CreateCommands()

	local function SetLift( Client, Enable)

		kEnabled = Enable 
	 	self.Config.Default = Enabled 
		self:SaveConfig()
		self:Notify( nil , "Lift set to %s" , true , Enabled  )	
	end
	local LiftCommand = self:BindCommand( "lft" , "lft" , Lift )
	LiftCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftCommand:Help( "Sets if should be enabled" )

	local function SetDev( Client, Enable )

		kLift = Enable 
		self.Config.kDev = Enabled
		self:SaveConfig()
		self:Notify( nil , "LiftDev is set to %s" , true , Enabled )	
	end
	local LiftDevCommand = self:BindCommand( "lftdev" , "lftdev" , SetLiftDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftDevCommand:Help( "Sets to  dev mode" )

	local function SetOffset( Client , y , x , z  )

		kOffset = Vector(  x  , y  , z )
		self.Config.kOffset = KOffset
		self:SaveConfig()
		self:Notify( Client , "Offset: Y %s  X %s  Z %s" , true , y , x , z  )
	end
	local LiftOffsetCommand = self:BindCommand( "lftos" , "lftos" , SetOffset )
	LiftOffsetCommand:AddParam{ Type = "number" , Optional = true Default = 0 }
	LiftOffsetCommand:AddParam{ Type = "number" , Optional = true , Default = 0 }
	LiftOffsetCommand:AddParam{ Type = "number" , Optional = true , Default = 0 }
	LiftOffsetCommand:Help( "Sets the offset y x z" )

	local function SetTolerance( Client, tolerance )

		kTolerance = tolerance 
		self.Config.kTolerance = tolerance
		self:SaveConfig()
		self:Notify( Client  , "Lift Tolerance is set to %s " , true , tolerance )
	end
	local LiftToleranceCommand = self:BindCommand( "lftol" , "lftol" , SetTolerance )
	LiftToleranceCommand:AddParam{ Type = "number" , Optional = true , Default = 0.28 }
	LiftToleranceCommand:Help( "Sets the tolerance" )

end

function Plugin:Cleanup()

	kLiftEnabled = false 
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
