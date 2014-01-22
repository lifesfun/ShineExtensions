ObjChannel = { 

	Name = nil, 
	Password = nil , 
	Clients = {}
}

function ObjChannel:new( o )
	
	o = o or {}
	setmetatable( o , self ) 
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

	Names = {}

	for Client , Name in pairs( self.Clients ) do
		
		Names[ Client ] = Name 
	end

	return Names 

end

function ObjChannel:GetClients() 
	
	return self.Clients
end	

