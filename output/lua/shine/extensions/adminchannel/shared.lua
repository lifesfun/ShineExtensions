local Plugin = {}

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "ActiveAdminTalk" , {} , "Server" ) 
end

if Server then

	function Plugin:ReceiveActiveAdminTalk( Client , Message ) 
	
		if Shine:HasAccess( Client , "sh_adminchannel" ) then
	
			local ID = tostring( Client:GetUserId() )
	
			if self.ActiveAdminTalk[ Client ] == false then 
		
				self:Notify( Client, "Admin Talk Active" ) 
				self.ActiveAdminTalk[ Client ] = true
			else
		
				self.ActiveAdminTalk[ Client ] = false
				self:Notify( Client, "Admin Talk has been unactivated" ) 
		end
	end
end

Shine:RegisterExtension( "adminchannel" , Plugin )

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

		self:SendNetworkMessage(  "ActiveAdminTalk" , {} , true )
		
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
	local SetAdminKeyCommand = self:BindCommand( "sh_setadminkey" , SetAdminKey ) 
	SetAdminKeyCommand:AddParam{ Type = "string" , MaxLength = 1 , Optional = false } 
end

function Plugin:Cleanup()
	
	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end
