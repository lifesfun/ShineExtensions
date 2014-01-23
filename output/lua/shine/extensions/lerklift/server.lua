--Extended the original to be used with shine. See LerkLift.lua for authors information. Thanks to the author Hackepeter 

local Shine = Shine

local Plugin = {} 

Plugin.HasConfig = false

Script.Load( "lua/shine/extensions/lerklift/LerkLiftMod.lua" )

function Plugin:Initialise()
	
	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , "LerkLiftMod" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:CreateCommands()

	local function LerkLift(client, enable)

		if enable ~= nil then

			Alien.kLiftEnabled = tonumber(enable) ~= 0			
		end

		Print( string.format( "LerkLiftMod is %d", ConditionalValue( Alien.kLiftEnabled , 1 , 0 ) , enable ) )
		self:Notify( nil , "LerkLiftMod is %s" , true , Alien.kLiftEnabled  )	

	end
	local LerkLiftCommand = self.BindCommand( "lerklift" , "lerklift" , LerkLift )
	LerkLiftCommand:AddParam{ Type = "string" }
	LerkLiftCommand:Help( "Type lerklift 1/0 to enable or disable" )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	Alien.kLiftEnabled = false 
end

Shine:RegisterExtension( "lerklift" , Plugin )
