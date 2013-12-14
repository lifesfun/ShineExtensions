local Plugin = Plugin 

Plugin.Commands = {} 

function Plugin:Initialise()

	self.Enabled = true

	return true

end
	
function PlayerKeyPress( Key , Down , Amount )

	if Key == "P" then
	
		self:SendNetworkMessage( "AdminVoice" , {} , true )

	end

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self ) 

end
