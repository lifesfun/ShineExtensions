local Plugin = {}

Shine:RegisterExtension( "channels" , Plugin )

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Active" , { Boolean = "boolean" } , "Server" ) 
end

