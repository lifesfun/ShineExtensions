local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner
local FixArray = table.FixArray

Script.Load( "lua/shine/extensions/channels/channel.lua" )
local ObjChannel = ObjChannel 


local Plugin = Plugin
Plugin.Version = "0.8"

Plugin.HasConfig = true
Plugin.ConfigName = "Channels.json"
Plugin.DefaultConfig = { 

	TempCreate = true --all players can create temp channels
}

Plugin.CheckConfig = true
Plugin.DefaultState = true 

Plugin.Active = {} 
Plugin.Clients = {} 
Plugin.Channels = {} 


function Plugin:Initialize()

	self:CreateCommands()	

	self:CreateChannel( "none" , "PUBLIC" )
	self:CreateChannel( "admin" , "admin" )
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

	if not Client then return end
	if Client:GetIsVirtual() then return end

	self.Active[ Client ] = false
	
	self:MoveToChannel( Client , "none" , "PUBLIC" ) 

	self:SimpleTimer( 4 , function() 

		self:Notify( Client, "Channels are enabled." ) 
		self:Notify( Client, "To switch channels type  [ !# 'ChannelName/options/off' Password]" ) 
		self:Notify( Client, "To create type [ !#+ 'ChannelName Password ]" ) 
		self:Notify( Client, "Leave to the password blank for public channels." )
	end )
end 

function Plugin:ClientDisconnect( Client )
	
	self.Clients[ Client ] = nil
	self.Active[ Client ] = nil

	local Channel = self:GetClientByChannel( Client )
	if not Channel then return end	
	Channel:RemoveClient( Client ) 	
end

function Plugin:CreateChannel( ChannelName , Password )

	self:Notify( nil , "Channel %s is being created.", true , ChannelName ) 
	if self:GetChannelByName( ChannelName ) then return end
	
	self.Channels[ #self.Channels + 1 ] = ObjChannel:new{ Name = ChannelName , Password = Password } 
end

function Plugin:GetChannelByClient( Client ) 

	return self.Clients[ Client ]  	
end

function Plugin:GetChannelByName( ChannelName )

	if not self.Channels then return end

	for Key , Value in ipairs( self.Channels ) do 
		
		if self.Channels[ Key ]:GetName() == ChannelName then return self.Channels[ Key ] end
	end
end

function Plugin:GetChannelNames()

	local Names = {} 
	for Key , Value in ipairs( self.Channels ) do 
		
		Names[ Key ] = Value:GetName() 
	end
	return Names
end

function Plugin:MoveToChannel( Client , ChannelName , Password )

	local NewChannel = self:GetChannelByName( ChannelName ) 
	if not NewChannel then return end
	if not NewChannel:HasAccess( Password ) == true then return end 

	local OldChannel = self:GetChannelByClient( Client )
	if OldChannel then OldChannel:RemoveClient( Client ) end

	NewChannel:AddToChannel( Client , Client:GetControllingPlayer():GetName() ) 	

	self.Clients[ Client ] = NewChannel
	self:Notify( Client , "moving to channel... %s" , true , ChannelName ) 
	self:UpdateChannel( NewChannel )
end

function Plugin:ReceiveActive( Client , Active) 

	self.Active[ Client ] = Active.Boolean
end

function Plugin:SendOptions( Client )

	local ChannelNames = self:GetChannelNames() 

	self.Notify( Client , "Channel Options" )
	for Key , Value in pairs( ChannelNames ) do

		self.Notify( Client , Value )
	end
end

function Plugin:UpdateChannel( Channel ) 

	local ChannelName = Channel:GetName()
	local ClientNames = Channel:GetClientNames()

	for Key , Value in pairs( ClientNames ) do
		local Client = Key
		
		for Key , Value in pairs( ClientNames ) do

			self.Notify( Client , Value )
		end
	end
end

function Plugin:SameChannel( ListenerClient , SpeakerClient ) 

	local ListenerChannel = self:GetChannelByClient( Listener ):GetName() 
	local SpeakerChannel = self:GetChannelByClient( Speaker ):GetName() 
	
	if ListenerChannel == SpeakerChannel then return end
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	local SpeakerClient = GetOwner( Speaker ) 
	local ListenerClient = GetOwner( Speaker ) 
	local SameChannel = self:SameChannel( ListenerClient , SpeakerClient )  

	local Active = self.Active[ SpeakerClient ] 

	if not Active == false and not SameChannel == false then return end
end 

function Plugin:CreateCommands()

	local function ChangeChannel( Client , Channel , Password ) 

		Channel:MoveToChannel( Client , Channel , Password )
	end
	local ChangeChannelCommand = self:BindCommand( "sh_change" , "change" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "none" }  
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	ChangeChannelCommand:Help( "[ change ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password ) 

		if self.TempCreate == false and not Shine:HasAcess( Client , "sh_channel" ) then return end
		Channel:CreateChannel( Client , Channel , Password )
		Channel:MoveToChannel( Client , Channel , Password )
	end
	local CreateChannelCommand = self:BindCommand( "sh_add" , "add", CreateChannel , true )
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	CreateChannelCommand:Help( "[ add ChanneName Password ] Change create" )
	
end


function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

