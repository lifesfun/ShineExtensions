local Plugin = Plugin

local Encode, Decode = json.encode, json.decode
local StringFormat = string.format
local StringExplode = string.Explode 

Plugin.HasConfig = true
Plugin.ConfigName = "AdminTalkKey.json"

Plugin.DefaultConfig = { 	

	ToggleKey= "P",
	Channel = "off" 
}

Plugin.CheckConfig = true

function Plugin:Initialise()
	self.ToggleKey = self.Config.ToggleKey 
	self.Channel = self.Config.Channel

	if self.Channel == nil then 
		self:ChangeChannel( "off" ) 
	end

	if self.Channel == nil then 
		self:ChangeKey( "P" )
	end

	self.Active = false	

	self:CreateCommands()

	self.Enabled = true

	return true
end

function ReceiveCurrentChannel( Data )

	if Data.Name == nil then 

		self:SendNetworkMessage( "Channel" , { String = self.Channel } , true )  
	else
		
		Shine:AddMessageToQueue( 7 , 0.95, 0.2, Data.Name  , true , 255, 0, 0, 2 )
	
		local Content = Data.Contents 
		Shine:AddMessageToQueue( 7 , 0.95, 0.2, Content , true , 255, 0, 0, 2 )
	
	end	
end

function Plugin:Activate()

	local Message = StringFormat( "Channel Activated" ) 

	if self.Active == true then

		self.Active = false
	else
		self.Active = true
	end

	Shine:AddMessageToQueue( 11 , 0.95, 0.2, Message , self.Active , 255, 0, 0, 2 )
	self.SendNetworkMessage( "Activate" , { Boolean = self.Active } , true )  
end

function Plugin:ChangeToggleKey( String )

	self.ToggleKey = String
	self.Config.ToggleKey = String
	self:SaveConfig()

	local Message = StringFormat( "You have set your toggle channel key to '%s'", String  ) 
	Shine:AddMessageToQueue( 1, 0.95, 0.2, Message , 2 , 255, 0, 0, 2 )
end

function Plugin:ChangeChannel( String )

	if String == "off" then return end
	self.SendNetworkMessage( "Channel" , { String = String } , true )  
	self.Channel = String
	self.Config.Channel = Channel 
	self:SaveConfig()
end

function PlayerKeyPress( Key , Down , Amount )

	if self.Channel == "off" then return true end
	if Key == self.ToggleKey then
		self:Activate()
		return true
	end
end

function Plugin:CreateCommands()

	local function ChannelKey( String )

		self:ChangeKey( String )

	end
	local ChannelKeyCommand = self:BindCommand( "sh_channelkey" , ChangeToggleKey ) 
	ChannelKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false , Default = "P" } 
	ChannelKeyCommand:Help("[sh_channelKey 'Key'] Key should be upppercase. Key toggles channel.")

	local function Channel( String )
	
		self:ChangeChannel( String ) 

	end
	local ChannelCommand = self:BindCommand( "sh_channel" , Channel ) 
	ChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "channel" } 
	ChannelCommand:Help("[sh_channel 'ChannelName' ]Enables or disables the channel.") 
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end
