local Shine = Shine

local Notify = Shard.Message

local GetOwner = Sever.GetOwner

local Plugin = Plugin
local Plugin.Version = "0.5"

Plugin.HasConfig = true
Plugin.ConfigName = "ExtraVoiceCmds.json"

Plugin.DefaultConfig = { 

	Delay = 5,
	AdminChat = true
	self.Config.Admins = {} 

}

Plugin.CheckConfig = true

Plugin.Commands = {}

function Plugin:Initialize()

	self:CreateCommands()

	self.Enabled = true

	return true

end

function Plugin:Notify( Player , String Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "ExtraVoiceCmds" , 255 ,  255 , 255 , String , Format , ... ) 

end

function Plugin:ClientConfirmConnect( Client ) 

	if Client:GetIsVirtual() then return end 

	local ID = Client:GetClientId() 

	if self.Config.AdminVoice == true and Shine:HasAccess( Client , "sh_adminvoice" )  then

		if self.Admins[ ID ] == nil then 

			self.Config.Admins[ ID ] = true 

		end

		Shine.Timer.Simple( self.Config.Delay , function() 

			self:Notify( Client, "AdminVoice enabled. To enable or disable[!adminvoice true/false]"  ) 

		end )

	end

end 

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	local ListenerClient = GetOwner( Listener )
	local SpeakerClient= GetOwner( Listener )
	local ListenerID = ListenerClient:GetClientId()
	local SpeakerID = SpeakerClient:GetClientId()
	
	if self.Config.AdminVoice == true and self.Config.Admins[ SpeakerID ] == true and self.Config.Admins[ ListnerID ] == true then 
		
		return true

	end

end


function Plugin:CreateCommands()
 
 	local Commands = self.Commands

	local function AdminVoice( Client , Command ) 

		if not Client then return end 

		local ID = Client:GetUserId()  
		if Command == true then

			self.Config.Admins[ ID ] = true 	
			self:SaveConfig()
			self:Notify( Client , "You have enabled adminvoice for yourself."  ) 

		elseif Command == false then 

			self.Config.Admins[ ID ] = false 
			self:SaveConfig()

			self:Notify( Client , "You have disabled adminvoice for yourself."  ) 

		end


	end

	Commands.AdminVoiceCommand = self:BindCommand( "sh_adminvoice" , { "adminvoice" } , AdminVoice , true) 
	Commands.AdminVoiceCommand:AddPara( Type = "boolean" , Optional = True , Default = true ) 
	Commands.AdminVoiceCommand:Help( "<true/false> Enables or disables admin voice locally." )

	local function EnableAdminVoice( Client , Command ) 

		if not Client then return end 

		if Command == true then

			self.Config.AllVoice = true
		
			self:Notify( Client , "AdminVoice Enabled for server"  ) 

		elseif Command == false then 

			self.Config.AllVoice = false 

			self:Notify( Client , "AdminVoice disabled for server"  ) 
		end


	end

	Commands.EnableAdminVoiceCommand = self:BindCommand( "sh_enableadminvoice" , { "enableadminvoice" } , EnableAdminVoice , false ) 
	Commands.EnableAdminVoiceCommand:AddPara( Type = "boolean" , Optional = True , Default = true ) 
	Commands.EnableAdminVoiceCommand:Help( "<true/false> Enables or disables the adminvoice globally." )

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 

	self.Enable = false

end

Shine:RegisterExtension( "extravoicecmds" , Plugin )
	
