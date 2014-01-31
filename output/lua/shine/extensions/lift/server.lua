--A mod that provides Lift functions and more!

local Shine = Shine

local kEnabled = kLiftEnabled 
local kDev = kLiftDev 


local Plugin = {} 
Plugin.Version = "1.0"

Plugin.HasConfig = true 
Plugin.ConfigName = "Lift.json"

Plugin.DefaultConfig = {

	Default = true,
	DevMode = false
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()

	kEnabled = self.Config.Default 
	kDev = self.Config.kDev

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
		self:Notify( Client , "Use e to lift up any living player as a gorge." )
end

function Plugin:CreateCommands()

	local function SetLift( Client, Enable)

		kEnabled = Enable 
	 	self.Config.Default = Enabled 
		self:SaveConfig()
		self:Notify( nil , "Lift Mod is set to %s" , true , Enabled  )	
	end
	local LiftCommand = self:BindCommand( "lft" , "lft" , SetLift )
	LiftCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftCommand:Help( "Sets if should be enabled" )

	local function SetDev( Client, Enable )

		kDev = Enable 
		self.Config.kDev = Enabled
		self:SaveConfig()
		self:Notify( nil , "LiftDev is set to %s" , true , Enabled )	
	end
	local LiftDevCommand = self:BindCommand( "lftdev" , "lftdev" , SetDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = false }
	LiftDevCommand:Help( "Sets to  dev mode" )
end

function Plugin:Cleanup()

	kLiftEnabled = false 
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
