local Plugin = Plugin

local Encode, Decode = json.encode, json.decode
local StringFormat = string.format
local StringExplode = string.Explode 

Plugin.HasConfig = true
Plugin.ConfigName = "AdminTalkKey.json"

Plugin.DefaultConfig = { 	

	ToggleKey= "P"
}

Plugin.CheckConfig = true

function Plugin:Initialise()

	self.ToggleKey = self.Config.ToggleKey or "P"  

	self.Active = false	

	self:CreateCommands()

	self.Enabled = true

	return true
end

function Plugin:PlayerKeyPress( Key , Down , Amount )

	if Key == self.ToggleKey then

		self:Activate()
		return true
	end
end

function Plugin:Activate()
	
	if self.Active == true then

		self.Active = false
	else
		self.Active = true
	end
	local Message = StringFormat( "ChannelActive:'%s'", self.Active  ) 
	Shine:AddMessageToQueue( 11 , 0.95, 0.2, Message , 5 , 255, 0, 0, 2 )
	self.SendNetworkMessage( "Activate" , { Boolean = self.Active } , true )  
end

function Plugin:ReceiveCurrentChannel( Data )

	if Data.Name ~= nil then 
		
		Shine:AddMessageToQueue( 7 , 0.95, 0.2, Data.Name , 5  , 255, 0, 0, 2 )
	
		Shine:AddMessageToQueue( 7 , 0.95, 0.2, Data.Content , 5 , 255, 0, 0, 2 )
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
	ChannelKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false , Default = "P" } 

end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end
