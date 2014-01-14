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

		self.Active[ Client ] = Active.Boolean
	end
	
	function Plugin:SendOptions( Client )

		ClientChannel.Name = "Channel Options" 

		local Names = self:GetChannelNames() 
		ClientChannel.Contents = concat( Names , "," )  

	
		self:SendNetworkMessage( Client , "Channel" , ClientChannel , false  ) 
	end

	function Plugin:UpdateChannel( Channel ) 

		ClientChannel.Name = Channel:GetName()

		local Names = Channel:GetClientNames()
		ClientChannel.Contents = concat( Names , "," ) 

		for Key , Value in pairs( Channel.Clients ) do

			self:SendNetworkMessage( Key , "Channel" , ClientChannel , false  ) 
		end
	end

end
