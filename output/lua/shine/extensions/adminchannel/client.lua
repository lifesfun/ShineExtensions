local Plugin = Plugin 

Plugin.HasConfig = true
Plugin.ConfigName = "AdminTalkKey.json"
Plugin.DefaultConfig = { 	

	AdminTalkKey = "J"
}

Plugin.CheckConfig = true
Plugin.SilentConfigSave = true

Plugin.Commands = {} 

function Plugin:Initialise()

	self.Enabled = true

	return true
end
	
function PlayerKeyPress( Key , Down , Amount )

	if Key == self.Config.AdminTalkKey then

		self:SendNetworkMessage( "ActiveAdminTalk" , true , true )
	else

		self:SendNetworkMessage( "ActiveAdminTalk" , false , true )
	end
end

function Plugin:CreateCommands()

	local Commands = self.Commands

	local function SetAdminKey( Client , Value )

		self.Config.AdminTalkKey = Value
		self.SaveConfig()
	end
	Commands.AdminKeyCommand = self:BindCommand( "sh_setadminkey" , SetAdminKey ) 
	Commands.AdminKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false } 
	Commands.AdminKeyCommand:Help( "Sets Admin Key." )
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
end
