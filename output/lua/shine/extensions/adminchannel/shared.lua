local Plugin = {}

local ToString = table.ToString

local HasAccess = Shine.HasAccess
local CurrentChannel= { 
	Name = "string (25)",
	Contents = "string (255)"
}
	
Shine:RegisterExtension( "channels" , Plugin )

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "CurrentChannel" , CurrentChannel , "Client" )
	self:AddNetworkMessage( "Channel" , { String = "String (25)" } , "Server" ) 
	self:AddNetworkMessage( "Active" , { Boolean = "boolean" } , "Server" ) 
end

if Server then 
	function Plugin:ReceiveActive( Client , Active) 
		 self.Active[ Client ] = Active 
	end

	function Plugin:ReceiveChannel( Client , Channel ) 

		if not Shine:HasAccess( Client , Channel ) then 

			Channel = "off" 
		end 

		if Channel == "off" then 

			self.Channel[ Client ] = Client
			Currentchannel[ Contents ] = nil
			self:SendNetworkMessage( Client , "CurrentChannel" , CurrentChannel , true )
		else

			local Clients , local  Number = Shine:GetClientsWithAccess( Channel )
			Currentchannel[ Contents ] = ToString( Clients ) 
			CurrentChannel[ "Name" ] = Channel 
			self.Channel[ Client ] = Channel 

			for Key , Value in pairs( self.Channel ) do

				if Channel == Value then

					self:SendNetworkMessage( Client , "CurrentChannel" , CurrentChannel , true )
				end
			end
		end
	 end
end
