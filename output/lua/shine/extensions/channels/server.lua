local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner
local TableCount = table.Count
local TableEmpty = table.Empty

local Plugin = Plugin
Plugin.Version = "1.7"

Plugin.HasConfig = true
Plugin.ConfigName = "Channels.json"
Plugin.DefaultConfig = { 

	DefaultChannel= "options",

	TempChannels = true, --#channename creates a channel if it does not exist
	TempCreate = true, --all players can create temp channels

	Channels = '.admin', 'AllTalk' --creates permanent channels '.' hidden from public 
}

Plugin.CheckConfig = true
Plugin.DefaultState = true 
	
function Plugin:Initialize()
	
	self.DefaultChannel = self.Config.DefaultChannel or "options"
	self.TempChannels = self.Config.TempChannels or false

	self.Channels =  self.Config.Channels 

	self.CurrentChannel = nil
	self.Active = nil 
	
	self:CreateCommands()
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConnect( Client )
 
 	self.CurrentChannel[ Client ] = self.DefaultChannel 
	self.Active[ Client ] = false	

	self:SimpleTimer( 4 , function() 

		self:Notify( Client, "Channels are enabled." ) 
		self:Notify( Client, "To switch channels type  [ !# 'ChannelName/options/off' Password]" ) 
		self:Notify( Client, "To create type [ !#+ 'ChannelName Password ]" ) 
		self:Notify( Client, "Leave to the password blank for public channels." )

	end )
end 

function Plugin:ClientDisconnect( Client ) 

	local Channel = self.CurrentChannel[ Client ]
	self.Channels[ Channel ][ Client ] = nil
	if TableCount( self.Channels[ Channel ] ) <=1 then  

		TableEmpty( self.Channels[ Channel ] )
	end
	self.CurrentChannel[ Client ] = nil
	self.Active[ Client ] = nil
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	local Active = self.Active[ SpeakerClient ]

	if self.InChannel( Listener , Speaker ) and Active == true then return true end
end 

function Plugin:InChannel( Listener , Speaker )

	local ListenerClient = GetOwner( Listener )
	local SpeakerClient = GetOwner( Speaker ) 
	local ListenerChannel = self.CurrentChannel[ ListenerClient ] 
	local SpeakerChannel = self.CurrentChannel[ SpeakerClient ] 

	if ListenerChannel == "options" or SpeakerChannel == "options" then return false end
	if ListenerChannel == SpeakerChannel then return true end

	return false 
end 

function Plugin:CreateCommands()

	local function Options()
	
		self.CurrentChannel[ Client ] = "options"
	end

	local function AddToChannel( Client , Channel )

		local PreviousChannel = self.CurrentChannel[ Client ] 	

		if PreviousChannel ~= "options" then 

			self.Channels[ PreviousChannel ][ Client ] = nil
			self.UpdateChannel( PreviousChannel )
		end

		self.CurrentChannel[ Client ] = Channel	
		self.Channels[ Channel ][ Client ] = Client:GetControllingPlayer():GetName()  
		self.UpdateChannel( Channel )
		
		self:Notify( Client , "You are in Channel '%s'" , true , Channel ) 

	end

	local function ChangeChannel( Client , Channel , Password ) 

		if Channel == "options" then Options() return end 

		if self.Channels[ Channel ].Password ~= Password then 

			self:Notify( Client , "Incorrect Password for %s" , true , Channel ) 

		elseif self.Channel[ Channel ].Password == Password then 
		
			AddToChannel( Client , Channel )
		else 
			
			self.CurrentChannel[ Client ] = "options"	
			self:Notify( Client , "%s is not a valid channel." , true , Channel ) 
		end
	end
	local ChangeChannelCommand = self:BindCommand( "sh_#" , "#" , ChangeChannel , true )
	ChangeChannelCommand:AddParam{ Type = "string" }  
	ChangeChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	ChangeChannelCommand:Help( "[ # ChanneName Password ] Change channels" )

	local function CreateChannel( Client , Channel , Password )  

		if self.TempChannels == false then return end
		if self.TempCreate == false and Shine:UserHasAcess( Client , "sh_channel" ) then return end
		if Channel == "options" then Options() return end 

		if self.Channels[ Channel ] == nil then

			self.Channels[ Channel ].Password = Password
			AddToChannel( Client , Channel )
			self:Notify( Client , "You have created the Channel %s" , true , Channel ) 
		else	
			self:Notify( Client , "The Channel '%s' with the password '%s' is invalid", true , Channel , Password ) 
			self:Notify( Client , "Try a different name." ) 
		end
	end
	local CreateChannelCommand = self:BindCommand( "sh_+#" , "+#" , CreateChannel , true )
	CreateChannelCommand:AddParam{ Type = "string" }  
	CreateChannelCommand:AddParam{ Type = "string" , Optional = true , Default = "PUBLIC" }  
	CreateChannelCommand:Help( "[ +# ChanneName Password ] Change create" )


function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

