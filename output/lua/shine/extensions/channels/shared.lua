local Plugin = {}

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Active" , {} , "Server" ) 
end

Shine:RegisterExtension( "channels" , Plugin )
