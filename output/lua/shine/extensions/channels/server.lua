local Shine = Shine

local Notify = Shared.Message
local GetOwner = Server.GetOwner

local Plugin = Plugin
Plugin.Version = "1.5"

function Plugin:Initialize()

	self.Active = {} 
	self.Channel = {} 
	
	self:CreateCommands()
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "ChannelBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:ClientConnect( Client )

	self.Channel[ Client ] = Client 
	self.Active[ Client ] = false	
	
	if Shine:HasAccess( Client , "sh_channel" ) then

		self:SendNetworkMessage( Client , "CurrentChannel" , {} , true ) 

		self:SimpleTimer( 2 , function() 

			self:Notify( Client, "Channels are enabled." ) 
			self:Notify( Client, "[sh_channel 'ChannelName/options/off']" ) 
		end )
	end
end 

function Plugin:ClientDisconnect( Client ) 

	self.Channel[ Client ] = nil 
	self.Active[ Client ] = nil
end

function Plugin:CanPlayerHearPlayer( Gamerules , Listener , Speaker ) 

	local ListenerClient = GetOwner( Listener )
	local SpeakerClient = GetOwner( Speaker ) 
	local CanHear = Shine:HasAccess( ListenerClient , self.Channel[ ListenerClient ] ) 
	local CanTalk = Shine:HasAccess( SpeakerClient , self.Channel[ SpeakerClient ] )
	local Active = self.Active[ SpeakerClient ]

	if CanTalk  == true and CanHear == true and Active == true then return true end
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 
	self.Enable = false
end

