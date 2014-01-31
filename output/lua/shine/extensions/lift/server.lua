--A mod that provides Lift functions and more!
local Shine = Shine

local Plugin = {} 
Plugin.Version = "1.0"

Plugin.HasConfig = true 
Plugin.ConfigName = "Lift.json"

Plugin.DefaultConfig = {

	Default = true,
	Dev = false
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()

	kLiftEnabled = self.Config.Default 
	kLiftDev = self.Config.Dev

	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "LiftBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( client )

	self:TellPlayers( client ) 
end

function Plugin:TellPlayers( client )

	if not kLiftEnabled then return end
	self:Notify( client , "The Lift mod is Enabled!" )
	self:Notify( client , "Use e to lift up a gorge as a lerk." )
	self:Notify( client , "Use e to lift up any living player as a gorge." )
end

function Plugin:CreateCommands()

	local function SetLiftEnabled( client , enable )

		kLiftEnabled = enable 
	 	self.Config.Default = enabled 
		self:SaveConfig()
		self:TellPlayers( nil ) 
	end
	local LiftEnabledCommand = self:BindCommand( "lft" , "lft" , SetLiftEnabled )
	LiftEnabledCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftEnabledCommand:Help( "Sets if should be enabled" )

	local function SetLiftDev( client, enable )

		kLiftDev = enable 
		self.Config.kDev = enable
		self:SaveConfig()
		self:Notify( nil , "LiftDev is set to %s" , true , kLiftDev )	
	end
	local LiftDevCommand = self:BindCommand( "lftdev" , "lftdev" , SetLiftDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = false }
	LiftDevCommand:Help( "Sets to  dev mode" )
end

function Plugin:Cleanup()

	kLiftEnabled = false 
	self.Enabled = false
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
