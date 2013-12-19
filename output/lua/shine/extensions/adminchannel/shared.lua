local Plugin = {}

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "ActiveAdminTalk" , {} , "Server" ) 
end

Shine:RegisterExtension( "adminchannel" , Plugin )

if Server then

	function Plugin:ReceiveActiveAdminTalk( Client , Message ) 

		if self.Config.AdminTalk[ tostring( ID ) ] == nil then return end
		
		if self.ActiveAdminTalk[ Client ] == false then 
		
			self:Notify( Client, "Admin Talk Active" ) 
			self.ActiveAdminTalk[ Client ] = true
		else
		
			self.ActiveAdminTalk[ Client ] = false
			self:Notify( Client, "Admin Talk has been unactivated" ) 
		end
		
	end
	
	return 
end

if Server then return end

local Encode, Decode = json.encode, json.decode
local StringFormat = string.format

Plugin.HasConfig = true
Plugin.ConfigName = "AdminTalkKey.json"
Plugin.DefaultConfig = { 	

	AdminTalkKey = "J"
}

Plugin.CheckConfig = true

function Plugin:Initialise()
	
	self:CreateCommands()

	self.Enabled = true

	return true
end

function PlayerKeyPress( Key , Down , Amount )

	if Key == self.Config.AdminTalkKey then

		self:SendNetworkMessage( "ActiveAdminTalk" , {} , true )
		local Message = StringFormat( "AdminChat enabled using %s", Key  ) 
		 Shine:AddMessageToQueue( 1, 0.95, 0.2, Message , 5 , 255, 0, 0, 2 )
		
		return true
	end
end

function Plugin:CreateCommands()

	local function SetAdminKey( String )

		self.Config.AdminTalkKey = String
		self:SaveConfig()
		local Message = StringFormat( "You have set your admin channel key to %s", String  ) 
		 Shine:AddMessageToQueue( 1, 0.95, 0.2, Message , 5 , 255, 0, 0, 2 )
	end
	local AdminKeyCommand = Shine:RegisterClientCommand( "sh_setadminkey" , SetAdminKey ) 
	AdminKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false } 
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end
