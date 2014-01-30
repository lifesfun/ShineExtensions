local Plugin = {} 

Plugin.Version = "0.1"

Plugin.HasConfig = true 
Plugin.DefaultConfig = { 

	"nancy" = "sound/comtaunts.fev/taunts/",
	"ayumi" = "sound/comtaunts.fev/taunts/"
}

Plugin.CheckConfig = true 
Plugin.DefaultState = true 

function Plugin:Initialise() 

	self.Sounds = self.Config.Sounds
	self:CreateCommands()
	self.Enabled = true
	for key , value in pairs( self.Sounds ) do PrecacheAsset( key .. value ) end
end

function Plugin:OnRave( enable , origin )

	local players = GetEntitiesWithinRange( "Player", origin , 20 )
				
	for key , value  in pairs( players ) do 

		self:SendNetworkMessage( value , "Rave", { origin = origin } , true ) 
	end
end
	
function Plugin:CreateComands()

	local function OnSound( client , soundName , rave )

		local sound = self.Sound[ soundName ] 
		local player = client:GetControllingPlayer()		
		local origin = player:GetOrigin()

		self:OnRave( rave , origin )

		if sound == 0 then return end
		if sound then 

			--
			StartSoundEffectAtOrigin( sound , origin )
			self:Notify( client , "You have started %s" , true , soundName ) 
		else
			self:Notify( client , "There is no %s sound avaliable" , true , soundName ) 
		end
	end
	local OnSoundCommand = self:BindCommand( "play" , "play" , OnSound ) 
	OnSoundCommand:AddParam{ Type = "string" , Optional = true , Default = 0 }
	OnSoundCommand:AddParam{ Type = "boolean" , Optional = true , Default = false }
	OnSoundcommand:Help( "Type soundName enable or leave enable blank to disable the rave or the sound." )

	local function ListSounds( client )

		self:Notify( client , "Sounds Avaliable:" ) 
		for key , value in pairs( self.Sounds ) do

			self:Notify( client , "%s" , true , key ) 
		end
	end
	local ListSoundsCommand = self:BindCommand( "listsounds" , "listsounds" , ListSounds ) 
	ListSoundcommand:Help( "Lists the sounds avaliable." )

end

function Plugin:CleanUp()

	self.BaseClass.Cleanup( self ) 
	self.Enabled = false
end
