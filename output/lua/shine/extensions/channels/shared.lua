local Plugin = {}

local StringExplode = string.Explode
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

		 self.Active[ Client ] = Active 
	end

	function UpdateChannel( Channel ) 

		local Content = self.Channels[ Channel ] 
		Content.Password = nil

		ClientChannel.Name = Channel 
		ClientChannel.Contents = Concat( Content , "," ) 
		
		for Key , Value in pairs( Content )do

			self:SendNetworkMessage( Key , "Channel" , ClientChannel , false  ) 
		end
	end

end
