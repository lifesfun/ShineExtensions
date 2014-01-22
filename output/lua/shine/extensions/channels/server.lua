local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner
local FixArray = table.FixArray
local TimerCreate = Shine.Timer.Create
local TimerExists = Shine.Timer.Exists

local Plugin = Plugin

Plugin.Version = "0.8"

Plugin.DefaultState = true 

Script.Load( "lua/shine/extensions/channels/channel.lua" )
local ChannelObj = ObjChannel

Plugin.Active = {} 
Plugin.Clients = {} 
Plugin.Channels = {} 

function Plugin:Initialize()

	self:CreateCommands()

	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

	if not Client then return end
	if Client:GetIsVirtual() then return end

	self:CreateChannel( "admin" , "admin" )
	self.Active[ Client ] = false
	self:MoveToChannel( Client , "admin" , "admin" ) 

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

	local Channel = self:GetChannelByClient( Client )
	if not Channel then return end	
	Channel:RemoveClient( Client ) 	
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	if not Listener then return end 
	if not Speaker then return end

	local SpeakerClient = GetOwner( Speaker ) 
	local SpeakerChannel = self:GetChannelByClient( SpeakerClient ) 

	local ListenerClient = GetOwner( Listener ) 
	local ListenerChannel = self:GetChannelByClient( ListenerClient ) 

	local Active = self.Active[ SpeakerClient ] 
	
	if SpeakerChannel == ListenrChannel and Active == true then return true end
end 

function Plugin:GetChannelByClient( Client ) 

	return self.Clients[ Client ]  	
end

function Plugin:GetChannelByName( ChannelName )

	if not self.Channels then return end

	for Key , Value in pairs( self.Channels ) do 

		local Channel  = self.Channels[ Key ]
		local Name = Channel:GetName() 

		self:Notify( nil , "Player being moved to %s", true , ChannelName ) 
		if ChannelName == Name then return Channel end
	end
end

function Plugin:CreateChannel( ChannelName , Password )

	if self:GetChannelByName( ChannelName ) then return end
	self:Notify( nil , "Channel %s is being created.", true , ChannelName ) 
	
	self.Channels[ #self.Channels + 1 ] = ChannelObj:new{ Name = ChannelName , Password = Password } 
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

function Plugin:ReceiveActive( Client ) 
 
	if TimerExists( "Active" ) then return end
	
	TimerCreate( "Active" , 0.1 , 1 ,  function() 

		local Active =	self.Active[ Client ]
		if self.Active[ Client ] == true then 
		
			self.Active [ Client ] = false 
			self:Notify( Client , "UnActive" )
		else 

			self.Active[ Client ] = true 
			self:Notify( Client , "Active" )
		end
	end )
end

function Plugin:UpdateChannel( Channel ) 

	local ClientNames = Channel:GetClientNames()

	for Client , Name in pairs( ClientNames ) do

		local ChannelClient = Client 
		
		for Key , Value in pairs( ClientNames ) do

			self.Notify( Client , "%s  : %s " , true , Key , Value )
		end
	end
end

function Plugin:SendOptions( Client )

	local ChannelNames = self:GetChannelNames() 

	self.Notify( Client , "Channel Options" )
	for Key , Value in pairs( ChannelNames ) do

		self.Notify( Client , Value )
	end
end

function Plugin:GetChannelNames()

	local Names = {} 
	for Key , Value in ipairs( self.Channels ) do 
		
		Names[ Key ] = self.Channels[ Key ]:GetName() 
	end
	return Names
end

function Plugin:CreateCommands()

	local function ChangeChannel( Client , Channel , Password ) 

		self:MoveToChannel( Client , Channel , Password )
	end

	local ChangeChannelCommand = self:BindCommand( "sh_changechannel" , "changechannel" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" }  
	ChangeChannelCommand:AddParam{ Type = "string" } 
	ChangeChannelCommand:Help( "[ change ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password ) 

		self:CreateChannel( Client , Channel , Password )
		self:MoveToChannel( Client , Channel , Password )
	end

	local CreateChannelCommand = self:BindCommand( "sh_createchannel" , "createchannel", CreateChannel )
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:Help( "[ add ChanneName Password ] Change create" )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

