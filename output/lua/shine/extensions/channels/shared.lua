local Plugin = {}

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Active" , { Boolean = "boolean" } , "Server" ) 
end

Shine:RegisterExtension( "channels" , Plugin )
