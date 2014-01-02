local Channel = {} 

Channel.Clients = { {}  , {} } 

function Channel:AddClient( Client ) 

	self.Clients[ Client ] = { Client , Client:GetControllingPlayer():GetName() } 
end

function Channel:RemoveClient( Client )

	self.Clients[ Client ] = nil  
end

function Channel:GetClients()

	return self.Clients[ 1 ] 
end

function Channel:GetNames()
	
	return self.Clients[ 2 ]
end

		



