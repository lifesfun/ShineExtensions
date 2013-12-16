local Plugin = Plugin 

Plugin.HasConfig = true
Plugin.DefaultConfig = "AdminTalkKey.json"
Plugin.DefaultConfig = { 	

	AdminTalkKey = "j"
}

Plugin.CheckConfig = true

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

	local function SetAdminTalkKey( Client , Value )

		self.Config.AdminTalkKey = Value
		self.SaveConfig()
	end
	Commands.AdminTalkKeyCommand = self:BindCommand( "sh_admintalkkey" , SetAdminTalkKey ) 
	Commands.AdminTalkKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false } 
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
end
