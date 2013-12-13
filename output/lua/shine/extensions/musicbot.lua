local Shine = Shine

local Notify = Shard.Message
local GetAllClients = Shine.GetAllClients 

local Encode, Decode = json.encode, json.decode
local tostring = tostring 

local Plugin = Plugin
local Plugin.Version = "0.8"

Plugin.HasConfig = true
Plugin.ConfigName = "RadioBot.json"

Plugin.DefaultConfig = { 

	Enabled = true,
	Stream = "http://hello.com",
	RadioClientIDs = {}, 
	Delay = 5

}

Plugin.CheckConfig = true

Plugin.Commands = {}

function Plugin:Initialize()

	self:CreateCommands()

	self.Enabled = true

	return true

end

function Plugin:Notify( Player , String Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "RadioBot" , 255 ,  255 , 255 , String , Format , ... ) 

end

function Plugin:ClientConfirmConnect( Client ) 

	if Client:GetIsVirtual() then return end 

	if self.Config.Enabled == false then return end

	Shine.Timer.Simple( self.Config.Delay , function() 

		self.Notify( Client , "Tune in to the radio by typing !radiobot in chat :D" )

	end )

	local ID = Client:GetUserId()   

	if self.Config.RadioClientIDs[ tostring( ID ) ] == true then 
		
		Server.SendNetworkMessage( Client , "Shine_Web" , { URL = self.Config.Stream , Title = "Radio Bot" }, true )
		self:Notify( Client , "The radio stream has been enabled for you.[ !radiobot true/false ]"  ) 

	end

end 

function Plugin:CreateCommands()
 
 	local Commands = self.Commands

	local function SetRadio( Client , Command ) 
	
		if not Client then return end 
		
		if self.Config.Enabled == false then return end

		local ID = Client:GetUserId()  
		
		if Command == true then

			self.Config.RadioClientIDs[ tostring( ID ) ] = true 
	
			Server.SendNetworkMessage( Client , "Shine_Radio" , { URL = self.Config.Stream , Title = "Radio Bot" }, true )
			self:Notify( Client , "The radio stream has been enabled for you.[ !radiobot true/false ]"  ) 

		elseif Command == false then 

			self.Config.RadioClientIDs[ tostring( ID ) ] = false 
				
			Server.SendNetworkMessage( Client , "Shine_Radio" , CloseWindow ,  true )

			self:Notify( Client , "The radio stream has been disabled for you.[ !radiobot true/false ]"  ) 
		end

		self:SaveConfig() 

	end

	Commands.SetRadioCommand = self:BindCommand( "sh_radiobot" , { "radiobot" } , SetRadio , true) 
	Commands.SetRadioCommand:AddPara( Type = "boolean" , Optional = true , Default = true ) 
	Commands.SetRadioCommand:Help( "<true/false> Enables or disables the RadioBot." )

	local function EnableRadio( Client , Command ) 
	
		if not Client then return end 

		local ID = Client:GetUserId()  
		
		if Command == true then

			self.Config.Enabled = true 

			local RadioClientIDs = self.Config.RadioClientIDs

			local Clients = GetAllClients() 


			for Key , Value in pairs( Client  ) do 
			
				if RadioClientIDs[ Value:GetUserId() ] == true then 

					Server.SendNetworkMessage( Value , "Shine_Radio" , { URL = self.Config.Stream , Title = "Radio Bot" }, true )
				end
						

			end

			self:Notify( Client , "The radio is enabled for the server. [ !EnableRadio true/false ]"  ) 

		elseif Command == false then 

			self.Config.Enabled = false 

			for Key , Value in pairs( Client  ) do 
			
				if RadioClientIDs[ Value:GetUserId() ] == true then 

					Server.SendNetworkMessage( Value , "Shine_Radio" , CloseWindow , true )
				end
						

			end


			self:Notify( Client , "The radio is disabled for the server. [ !EnableRadio true/false ]"  ) 
		end

		self:SaveConfig() 	

	end

	Commands.SetRadioCommand = self:BindCommand( "sh_enableradio" , { "enableradio" } , EnableRadio , false ) 
	Commands.SetRadioCommand:AddPara( Type = "boolean" , Optional = true , Default = true ) 
	Commands.SetRadioCommand:Help( "<true/false> Turns the RadioBot on or off for the server." )


end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 

	self.Enable = false

end

Shine:RegisterExtension( "radiobot" , Plugin )
	
