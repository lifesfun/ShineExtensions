Obj.Channel = { 

	Name = nil, 
	Password = "PUBLIC", 
	Clients = {}
}

function Obj.Channel:new( o )
	
	o = o or {}
	setmetable( o , self ) 
	self._index = self 
	return o 
end

function Obj.Channel:GetName()
	
	return self.Name
end

function Obj.Channel:CanAccess( Password )

	if self.Password == Password then return true end
end

function Obj.Channel:AddClient( Client , Name )
	
	self.Clients[ Client ] = Name
end

function Obj.Channel:RemoveClient( Client )
	
	local ClientName = self.Clients[ Client ]   
	if not ClientName then return end
		
	self.Clients[ Client ] = nil  
end

function Obj.Channel:GetClientNames() 
	
	local Names = {} 
	for Key , Value in pairs( self.Clients ) do

		ChannelClients[ Client ] = Value
	end

	return Names
end

function Obj.Channel:GetClients() 
	
	return self.Clients
end	

