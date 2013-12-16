local Plugin = Plugin

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "ActiveAdminTalk" , { ActiveAdminTalk = "boolean" } , "Server" ) 
end

Shine:RegisterExtension( "adminchannel" , Plugin )
