local Shine = Shine

local Notify = Shard.Message

local GetOwner = Sever.GetOwner

local Plugin = Plugin
local Plugin.Version = "0.8"

Plugin.HasConfig = true
Plugin.ConfigName = "AdminChannel.json"

Plugin.DefaultConfig = { 

	Delay = 5,
	AdminTalk= {} 
}

Plugin.CheckConfig = true
Plugin.Commands = {}

function Plugin:Initialize()

	self:CreateCommands()

	self.ActiveAdminTalk = {}

	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "AdminChannel" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client ) 

	if Client:GetIsVirtual() then return end 
	if not Client then return end 

	local ID = Client:GetClientId() 
	
	if self.Config.AdminTalk[ ID ] then 

		self.ActiveAdminTalk[ Client ] = false 
	
		self.SimpleTimer( self.Config.Delay , function() 

			self:Notify( Client, "The Admin Channel is enabled for you. To enable or disable[!adminchannel true/false]"  ) 
		end )

	elseif Shine:HasAccess( Client , "sh_adminchannel" ) then 

		self.SimpleTimer( self.Config.Delay , function() 

			self:Notify( Client, "An Admin Channel is disable for you. To enable or disable[!adminchannel true/false]"  ) 
		end )
	end
end 

function Plugin:ClientDisconnect( Client )

	self.ActiveAdminTalk[ Client ] = nil 
end

function Plugin:ReceiveActiveAdminTalk( Client , ActiveAdminTalk ) 
	
		self.ActiveAdminTalk[ Client ] = ActiveAdminTalk 
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 
	
	local SpeakerClient= GetOwner( Speaker )
	local ListenerClient = GetOwner( Listener )
	local ListenerID = Client:GetUserId() 

	if self.Config.AdminTalk[ ListenerID ] == true and self.ActiveAdminTalk[ SpeakerClient ] == true then return end
end

function Plugin:CreateCommands()
 
 	local Commands = self.Commands

	local function AdminTalk( Client , Command ) 

		if not Client then return end 
		local ID = Client:GetUserId()  

		if Command == true then

			self.Config.AdminTalk[ ID ] = true 	
			self.ActiveAdminTalk[ Client ] = false 
			self:Notify( Client , "You have enabled Admin Channel for yourself." ) 

		elseif Command == false then 

			self.Config.AdminTalk[ ID ] = nil 
			self.ActiveAdminTalk[ Client ] = nil 
			self:Notify( Client , "You have disabled Admin Channel for yourself." ) 
		end

		self:SaveConfig()
	end
	Commands.AdminTalkCommand = self:BindCommand( "sh_admintalk" , { "admintalk" } , AdminTalk, false ) 
	Commands.AdminTalkCommand:AddPara( Type = "boolean" , Optional = true , Default = true ) 
	Commands.AdminTalkCommand:Help( "<true/false> Enables or disables admin voice locally." )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

