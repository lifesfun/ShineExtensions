local Shine = Shine

local Notify = Shared.Message
local Encode, Decode = json.encode, json.decode

local GetOwner = Server.GetOwner
local tostring = tostring

local Plugin = Plugin
Plugin.Version = "1.0"

Plugin.HasConfig = true
Plugin.ConfigName = "AdminChannel.json"

Plugin.DefaultConfig = { 

	Delay = 5,
	Delay = 5,
	AdminTalk= {} 
}

Plugin.CheckConfig = true

Plugin.ActiveAdminTalk = {}

function Plugin:Initialize()
	
	self:CreateCommands()
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "AdminChannel" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )
	
	if Shine:HasAccess( Client , "sh_adminchannel" ) then
	
		self.ActiveAdminTalk[ Client ] = false 
		local ID = tostring( Client:GetUserId() )
	
		if not self.Config.AdminTalk[ ID ] then  
			
			self.Config.AdminTalk[ ID ] = false
			self:SaveConfig()
		end
		
		self:SimpleTimer( self.Config.Delay , function() 
		
			self:Notify( Client, "The Admin Channel is enabled."  ) 
			self:Notify( Client, "To activate use [!adminchannel true/false]"  ) 
		end )
		
	end
end 

function Plugin:ClientDisconnect( Client )
	
	if Shine:HasAccess( Client , "sh_adminchannel" ) then
	
		self.ActiveAdminTalk[ Client ] = nil
	end
	
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 
	
	local SpeakerClient= GetOwner( Speaker )
	local ListenerClient = GetOwner( Listener )
	local ListenerID = tostring( ListenerClient:GetUserId() )

	if self.Config.AdminTalk[ ListenerID ] == true and self.ActiveAdminTalk[ SpeakerClient ] == true then 
		return true 
	end
end

function Plugin:CreateCommands()

	local function EnableAdminChannel( Client , Boolean ) 

		if not Shine:IsValidClient( Client ) then return end 
		local ID = tostring( Client:GetUserId() )

		if Boolean == false then

			self.Config.AdminTalk[ ID ] = true
			self:SaveConfig()			
			self:Notify( Client , "You have enabled Admin Channel for yourself." ) 

		else

			self.Config.AdminTalk[ ID ] = false
			self:SaveConfig()
			self:Notify( Client , "You have disabled Admin Channel for yourself." ) 
		end
		
	    self:Notify( Client, "To activate or deactivate use [!adminchannel true/false]"  ) 
		
	end
	local EnableAdminChannelCommand = self:BindCommand( "sh_adminchannel" , "!adminchannel"  , EnableAdminChannel ) 
	EnableAdminChannelCommand:AddParam{Type = "boolean"} 
	EnableAdminChannelCommand:Help("Enables admin channel for the current player")


end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

