local Plugin = Plugin

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "AdminVoice" , {} , "Server" ) 

end

Shine:RegisterExtension( "extravoicecommands" , Plugin )
