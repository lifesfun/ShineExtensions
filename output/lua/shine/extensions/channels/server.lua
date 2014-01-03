local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner

local Plugin = Plugin
Plugin.Version = "1.7"

Plugin.HasConfig = true
Plugin.ConfigName = "Channels.json"
Plugin.DefaultConfig = { 

	TempCreate = true, --all players can create temp channels
}

Plugin.CheckConfig = true
Plugin.DefaultState = true 

function Plugin:Initialize()

	self:CreateCommands()	

	self.Clients = {} 
	self.Channels = {} 

	local Channel = new Channel

	Channel:SetName( "none" )
	Channel:SetPassword( "PUBLIC" ) 

	self.AddChannel( Channel )
	
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

	if not Client then return end
	if Client:GetIsVirtual() then return end

	local ChannelClient =  { Client:GetControllingPlayer:GetName , false } 
	local Channel = self.GetChannelByName( "none" ) 

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
end

function Plugin:CreateChannel( ChannelName , Password = "PUBLIC" )

	if self.GetChannelByName( ChannelName ) then return end

	local Channel = new Channel

	Channel:SetPassword( Password )  
	Channel:SetName( ChannelName )  

	self.AddChannel( Channel )
end

function Plugin:AddChannel( Channel )	

	self.Channels[ self.Channels# + 1 ]  = new Channel 
end

function Plugin:GetClientChannel( Client ) 

	return self.Clients[ Client ]  	
end

function Plugin:GetChannelByName( ChannelName )

	for Key , Value in pairs( self.Channels ) do 
		
		if Value.Name == ChannelName then return Value end
	end
end

function Plugin:MoveToChannel( Client , ChannelName , Password )

	NewChannel = self.GetChannelByName( ChannelName ) 
	
	if not NewChannel then return end

	if not NewChannel:HasAccess( Password ) == true then return end 

	OldChannel = self.GetClientChannel( Client )

	local ChannelClient = OldChannel:RemoveClient( Client ) 	
		
	NewChannel:AddToChannel( Client , ChannelClient ) 	

	self.Clients[ Client ] = NewChannel

	if OldChannel.Name == "none" then return end	

	if not OldChannel:GetChannelClients() then 

		OldChannel = nil 
	end
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
	local ChangeChannelCommand = self:BindCommand( "sh_#" , "#" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" }  
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	ChangeChannelCommand:Help( "[ # ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password ) 

		if self.TempCreate == false and Shine:HasAcess( Client , "sh_channel" ) then return end
		Channel:CreateChannel( Client , Channel , Password )
	end
	local CreateChannelCommand = self:BindCommand( "sh_+#" , "+#" , CreateChannel , true )
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	CreateChannelCommand:Help( "[ +# ChanneName Password ] Change create" )
	
	end


function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

