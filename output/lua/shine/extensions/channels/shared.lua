local Plugin = {}

local concat = table.concat
local ClientChannel = { 

	Name = "string (25)",
	Content = "string (255)"
}
	
Shine:RegisterExtension( "channels" , Plugin )

function Plugin:SetupDataTable()
	
	self:AddNetworkMessage( "Channel" , ClientChannel , "Client" )
	self:AddNetworkMessage( "Active" , { Boolean = "boolean" } , "Server" ) 
end

if Server then 

	function Plugin:ReceiveActive( Client , Active) 

		 self.Active[ Client ] = Active 
	end
	
	function Plugin:SendOptions( Client )

		local Options = "( Public Channels do not require a pass )" 

		for Key , Value in pairs( self.Channels ) do

			if string.sub( Key , 1 , 2 ) ~= '.' or Shine:HasAccess( Client , "sh_channel" ) then  
				
				Options = Options..","..Key

				if Value.Password == 'PUBLIC' then 

					Options = Options.."Public" 	
				end

			end
		end
			
		ClientChannel.Name = Options 
		ClientChannel.Contents = Options 
		self:SendNetworkMessage( Client , "Channel" , ClientChannel , false  ) 
	end

	function Plugin:UpdateChannel( Channel ) 

		local Content = self.Channels[ Channel ] 
		Content.Password = nil

		ClientChannel.Name = Channel 
		ClientChannel.Contents = concat( Content , "," ) 
		
		for Key , Value in pairs( Content )do

			self:SendNetworkMessage( Key , "Channel" , ClientChannel , false  ) 
		end
	end

end
