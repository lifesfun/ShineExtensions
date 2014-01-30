local Plugin = Plugin 

local Plugin.Cinematic = nil 

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Rave" , { Origin  = "vector" }, " Client" )
end

Shine:RegisterExtension( "Sounds" , Plugin ) 
