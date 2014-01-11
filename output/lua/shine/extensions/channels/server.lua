local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner
local FixArray = table.FixArray

local Plugin = Plugin
Plugin.Version = "2.0"

Plugin.HasConfig = true
Plugin.ConfigName = "Channels.json"
Plugin.DefaultConfig = { 

	TempCreate = true, --all players can create temp channels
}

Plugin.CheckConfig = true
Plugin.DefaultState = true 

function Plugin:Initialize()

	Script.Load( "lua/shine/extensions/channels/channel.lua" )

	self:CreateCommands()	
	self.Clients = {} 
	self.Channels = {}
	self.CreateChannel( "none" , "PUBLIC" ) 
	
	self.Enabled = true

	return true
end
function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

	if not Client then return end
	if Client:GetIsVirtual() then return end

	local ChannelClient = { Client:GetControllingPlayer():GetName() , false } 
	local Channel = self:GetChannelByName( "none" ) 

	Channel:AddToChannel( Client , ChannelClient ) 	
	self.Clients[ Client ] = Channel
	
	self:SimpleTimer( 4 , function() 

		self:Notify( Client, "Channels are enabled." ) 
		self:Notify( Client, "To switch channels type  [ !# 'ChannelName/options/off' Password]" ) 
		self:Notify( Client, "To create type [ !#+ 'ChannelName Password ]" ) 
		self:Notify( Client, "Leave to the password blank for public channels." )
	end )
end 

function Plugin:ClientDisconnect( Client )
	
	self.GetClientChannel( Client ):RemoveClient( Client ) 	
	FixArray( self.Channels )
end

function Plugin:CreateChannel( ChannelName , Password )

	if self.GetChannelByName( ChannelName ) then return end

	self.Channels[ #self.Channels + 1 ] =  Channel:new{ Name = ChannelName , Password } 
end

function Plugin:GetClientChannel( Client ) 

	return self.Clients[ Client ]  	
end

function Plugin:GetChannelByName( ChannelName )

	if not self.Channels then return end

	for Key , Value in ipairs( self.Channels ) do 
		
		if Value:GetName() == ChannelName then return Value end
	end
end

function Plugin:MoveToChannel( Client , ChannelName , Password )

	local NewChannel = self.GetChannelByName( ChannelName ) 
	local OldChannel = self.GetClientChannel( Client )

	if not NewChannel or not OldChannel then return end
	if not NewChannel:HasAccess( Password ) == true then return end 

	NewChannel:AddToChannel( Client , OldChannel:RemoveClient( Client ) ) 	

	self.Clients[ Client ] = NewChannel
	self.UpdateChannel( NewChannel )
	FixArray( self.Channels )
end

function Plugin:CanHear( Listener , Speaker ) 

	if self.GetChannel( Listener ) == self.GetChannel( Speaker ) then return true end
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	if Plugin:CanHear( GetOwner( Listener ) , GetOwner( Speaker ) ) then return true end
end 

function Plugin:CreateCommands()

	local function ChangeChannel( Client , Channel , Password ) 

		Channel:MoveToChannel( Client , Channel , Password )
	end
	local ChangeChannelCommand = self:BindCommand( "sh_change" , "change" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" }  
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	ChangeChannelCommand:Help( "[ # ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password ) 

		if self.TempCreate == false and not Shine:HasAcess( Client , "sh_channel" ) then return end
		Channel:CreateChannel( Client , Channel , Password )
		Channel:MoveToChannel( Client , Channel , Password )
	end
	local CreateChannelCommand = self:BindCommand( "sh_add" , "add", CreateChannel , true )
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	CreateChannelCommand:Help( "[ +# ChanneName Password ] Change create" )
	
	end


function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end
