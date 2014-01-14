Channel = { 

	self.Name = nil, 
	self.Password = nil, 
	self.Clients = {  

		self.Name = nil,
		self.Active = nil 
	}
}

function Channel:new( o )
	
	o = o or {}
	setmetable( o , self ) 
	self._index = self 
	Shine:Notify( nil , "NEW" )
	return o 
end

function Channel:GetName()

	return self.Name
end

function Channel:Activate( Client , Active = false )

	self.Clients[ Client ] = Active 
end

function Channel:CanAccess( Password )

	if self.Password = Password then return true end
end

function Channel:AddToChannel( Client , ChannelClient )
	
	self.Clients[ Client ] = ChannelClient 	
end

function Channel:RemoveClient( Client )

	local ChannelClient = self.Clients[ Client ]

	if ChannelClient then 
	
		self.Clients[ Client ] = nil  
		if not self.GetChannelClients() then self.Channel = nil end
		return ChannelClient
	end
end

function Channel:GetChannelClients() 
	
	return self.Clients
end	

