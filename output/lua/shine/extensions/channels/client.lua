local Plugin = Plugin

local Encode, Decode = json.encode, json.decode
local StringFormat = string.format

Plugin.HasConfig = true
Plugin.ConfigName = "TalkKey.json"

Plugin.DefaultConfig = { 	

	ToggleKey= "p"
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()

	self.ToggleKey = self.Config.ToggleKey or "p"  

	self:CreateCommands()

	self.Enabled = true

	return true
end

function Plugin:PlayerKeyPress( Key , Down , Amount )

	if Key == InputKey[ self.ToggleKey ] then

		self:SendNetworkMessage( "Active" , {} , true )  

		return true
	end
end

function Plugin:CreateCommands()

	local function ChannelKey( String )

		self.Config.ToggleKey =  String 
		self.ToggleKey = String
		self:SaveConfig()

		local Message = StringFormat( "You have set your toggle channel key to '%s'", String  ) 
		Shine:AddMessageToQueue( 11 , 0.95, 0.2, Message , 5 , 255, 0, 0, 2 )
	end
	local ChannelKeyCommand = self:BindCommand( "channelkey" , ChannelKey ) 
	ChannelKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false , Default = "p" } 
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end

