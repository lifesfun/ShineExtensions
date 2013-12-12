local Shine = Shine

local Notify = Shard.Message

local Encode, Decode = json.encode, json.decode
local tostring = tostring 

local Plugin = Plugin
local Plugin.Version = "5.0"

Plugin.HasConfig = true
Plugin.ConfigName = "MusicBot.json"

Plugin.DefaultConfig = { 

	Stream = "http://hello.com",
	Music = {}, 
	Delay

}

Plugin.CheckConfig = true

Plugin.Commands = {}

function Plugin:Initialize()

	self:CreateCommands()

	self.Enabled = true

	return true

end

function Plugin:Notify( Player , String Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "MusicBot" , 255 ,  255 , 255 , String , Format , ... ) 

end

function Plugin:ClientConfirmConnect( Client ) 

	if Client:GetIsVirtual() then return end 

	Shine.Timer.Simple( self.Config.Delay , function() 

		self.Notify( Client , "I am am enabled, type !musicbot to listen in :D" )

	end )

	local ID = Client:GetUserId()   

	if self.Config.Music[ tostring( ID ) ] == true then 
	
		self:Notify( Client , "The music stream has been enabled for you.[!musicbot true/!musicbot false]"  ) 
		
		Server.SendNetworkMessage( Client , "Shine_Web" , { URL = self.Config.Stream , Title = "musicbot" }, true )

	end

end 

function Plugin:CreateCommands()
 
 	local Commands = self.Commands

	local function SetRadio( Client , Command ) 
	
		if not Client then return end 
	
		local ID = Client:GetUserId()  
		
		if Command == true then

			self.Config.Music[ tostring( ID ) ] = true 
	
			Server.SendNetworkMessage( Client , "Shine_Web" , { URL = self.Config.Stream , Title = "musicbot" }, true )
			self:Notify( Client , "The music stream has been enabled for you.[!musicbot true/!musicbot false]"  ) 

		elseif Command == false then 

			self.Config.Music[ tostring( ID ) ] = false 
				
			--closewebpage

			self:Notify( Client , "The music stream has been disabled for you.[!musicbot true/!musicbot false]"  ) 
		end

		self:SaveConfig() 

	end

	Commands.SetRadioCommand = self:BindCommand( "sh_musicbot" , { "musicbot" } , SetRadio , true) 
	Commands.SetRadioCommand:AddPara( Type = "boolean" , Optional = true , Default = true ) 
	Commands.SetRadioCommand:Help( "<true/false> Enables or disables the MusicBot." )

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 

	Table.Empty( self.Clients )
	self.Enable = false

end

Shine:RegisterExtension( "musicbot" , Plugin )
	
