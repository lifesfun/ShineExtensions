local Plugin = Plugin

Plugin.Cinematic = nil

function Plugin:ReceiveOrigin( origin )

	if self.Cinematic then

		Client.DestroyCinematic( cinematic )
		return 
	end

	local coords = Coords()
	--
	coords.origin = origin.origin

	self.Cinematic = Client.CreateCinematic( RenderScene.Zone_Default )
	self.Cinematic:SetCinematic( "cinematics/RAVE.cinematic" )
	self.Cinematic:SetCoords( coords )
	self.Cinematic:SetIsVisible( true )
	self.Cinematic:SetRepeatStyle( Cinematic.Repeat_Loop )
end
