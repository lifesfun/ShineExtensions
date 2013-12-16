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

		local Boolean = true 
	
		self:SendNetworkMessage( "ActiveAdminTalk" , { Boolean = Boolean } , true )
	end
end

function Plugin:CreateCommands()

	local function AdminChannelKey( Client , Value )

		self.Config.AdminTalkKey = Value
		self.SaveConfig()
	end

	local AdminTalKeyCommand = self:BindCommand( "sh_AdminTalkKey" , AdminChannelKey ) 
	AdminChannelKeyCommandi:AddParam{ Type = "string" , MaxLength = 1 , Optional = false } 

end
function Plugin:Cleanup()
	
	Shine:RemoveClientCommand( AdminTalkKeyCommand ) 
	self.BaseClass.Cleanup( self ) 
end
