Channel = { 

	self.Name = nil, 
	self.Password = nil, 
	self.Clients = {  

		self.Name = nil,
		self.Active = nil 
	}
}

function Channel:SetName( Name ) 
	
	self.Name = Name
end

function Channel:SetPassword( Password ) 

	self.Password = Password 
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
		return ChannelClient
	end
end

function Channels:GetChannelClients() 
	
	return self.Clients
end	


