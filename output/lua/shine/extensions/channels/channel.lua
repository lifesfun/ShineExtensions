ObjChannel = { 

	Name = nil, 
	Password = "PUBLIC", 
	Clients = {}
}

function ObjChannel:new( o )
	
	o = o or {}
	setmetable( o , self ) 
	self._index = self 
	return o 
end

function ObjChannel:GetName()
	
	return self.Name
end

function ObjChannel:CanAccess( Password )

	if self.Password == Password then return true end
end

function ObjChannel:AddClient( Client , Name )
	
	self.Clients[ Client ] = Name
end

function ObjChannel:RemoveClient( Client )
	
	local ClientName = self.Clients[ Client ]   
	if not ClientName then return end
		
	self.Clients[ Client ] = nil  
end

function ObjChannel:GetClientNames() 
	
	local Names = {} 
	for Key , Value in pairs( self.Clients ) do

		ChannelClients[ Client ] = Value
	end

	return Names
end

function ObjChannel:GetClients() 
	
	return self.Clients
end	

