local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner
local TableCount = table.Count
local TableEmpty = table.Empty
local Channels = obj.Channels
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
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConfirmConnect( Client )

	if not Client then return end
	if Client:GetIsVirtual() then return end

	self.AddChannel( Client , "none" , "none"  )
	
	self:SimpleTimer( 4 , function() 

		self:Notify( Client, "Channels are enabled." ) 
		self:Notify( Client, "To switch channels type  [ !# 'ChannelName/options/off' Password]" ) 
		self:Notify( Client, "To create type [ !#+ 'ChannelName Password ]" ) 
		self:Notify( Client, "Leave to the password blank for public channels." )

	end )
end 

function Plugin:MoveToChannel( Client , Name , Password )
	local Channel , local ChannelPass= self.Channels[ Name ] 

	if Password == ChannelPass then 
		AddToChannel Channel:Add( Client ) 


function Plugin:AddToChannel( Client , Name , Password )

	self.Channels[ Name ] = Channel:Add( Client ) , Password  
end

function Plugin:GetClientsChannel( Client ) 
	
	return self.Clients( Client ) 
end	

function Plugin:CanHear( Listener , Speaker ) 

	if GetClientsChannel( Listener ) == GetClientsChannel( Speaker ) then return true end
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	if Plugin:CanHear( GetOwner( Listener ) , GetOwner( Speaker ) ) then return true end

end 

function Plugin:CreateCommands()

	local function ChangeChannel( Client , Channel , Password ) 
		Channel:Add( Client , Channel , Password )
	end
	local ChangeChannelCommand = self:BindCommand( "sh_#" , "#" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" }  
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	ChangeChannelCommand:Help( "[ # ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password ) 

		if self.TempCreate == false and Shine:HasAcess( Client , "sh_channel" ) then return end
		Channel:Create( Client , Channel , Password )


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

