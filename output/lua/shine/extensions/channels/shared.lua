local Plugin = {}

local concat = table.concat
local ClientChannel = { 

	Name = "string (25)",
	Content = "string (255)"
}
	
Shine:RegisterExtension( "channels" , Plugin )

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Channel" , ClientChannel , "Client" )
	self:AddNetworkMessage( "Active" , { Boolean = "boolean" } , "Server" ) 
end

if Server then 

	function Plugin:ReceiveActive( Client , Active) 

		 Channel = self:GetClientChannel( Client )  
		 Channel:Activate( Client , Active )
	end
	
	function Plugin:SendOptions( Client )

		ClientChannel.Name = "( Public Channels do not require a pass )" 

		ClientChannel.Contents = concat( Channel.Name , "," ) 

		self:SendNetworkMessage( Client , "Channel" , ClientChannel , false  ) 
	end

	function Plugin:UpdateChannel( Channel ) 

		ClientChannel.Contents = concat( Channel.Clients.Name , "," ) 
		
		for Key , Value in pairs( Channel.Clients ) do

			self:SendNetworkMessage( Key , "Channel" , ClientChannel , false  ) 
		end
	end

end
