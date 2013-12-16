local Plugin = Plugin

function Plugin:SetupDataTable()

	self:AddNetworkMessage( "ActiveAdminTalk" , { Boolean = "boolean ( true or false )" } , "Server" ) 
end

if Server then

	function Plugin:ReceiveActiveAdminTalk( Client , Data ) 

		self.Boolean = Data.Boolean
	end
end

Shine:RegisterExtension( "adminchannel" , Plugin )
