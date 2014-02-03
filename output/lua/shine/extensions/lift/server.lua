--A mod that provides Lift functions and more!
kLiftEnabled = true
kLiftDev = false
local Shine = Shine
local GetOwner = Server.GetOwner

local Plugin = {} 
Plugin.Version = "1.0"

Plugin.HasConfig = true 
Plugin.ConfigName = "Lift.json"

Plugin.DefaultConfig = {

	Default = true,
	Dev = false
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

function Plugin:Initialise()

	kLiftEnabled = self.Config.Default 
	kLiftDev = self.Config.Dev
    self.Started = false
	self:CreateCommands()
	self.Enabled = true
	return true
end

function Plugin:Notify( Player , String , Format , ... ) 

	Shine:NotifyDualColour( Player , 0 , 100 , 255 , "LiftBot" , 255 ,  255 , 255 , String , Format , ... ) 
end

function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force, ShineForce ) 
	if OldTeam == 0 then 
		local client = GetOwner( Player )
		self:TellPlayers(  client ) 
	end
end
function Plugin:CheckGameStart( Gamerules )
	if Gamerules:GetGameState()  ==  kGameState.Started and self.Started == false then 
	
		self:TellPlayers(  nil ) 
		self.Started = true
	end
end
function Plugin:TellPlayers( client )
	local Gamerules = GetGamerules()
	if not kLiftEnabled or  Gamerules:GetGameState()  ==  kGameState.NotStarted  then return end
	self:Notify( client , "I am enabled :D" )
	self:Notify( client , "Press E to use Lift" )
	self:Notify( client , "Gorges can pick up any class, Lerks can pick up Gorges." )
end

function Plugin:CreateCommands()

	local function SetLiftEnabled( client , enable )

		kLiftEnabled = enable 
		self:TellPlayers( nil ) 
	end
	local LiftEnabledCommand = self:BindCommand( "lft" , "lft" , SetLiftEnabled )
	LiftEnabledCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftEnabledCommand:Help( "Sets if lift is enabled." )

	local function SetLiftDev( client, enable )

		kLiftDev = enable 
		self:Notify( nil , "LiftDev is set to %s" , true , kLiftDev )	
	end
	local LiftDevCommand = self:BindCommand( "lftdev" , "lftdev" , SetLiftDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = false }
	LiftDevCommand:Help( "Sets to  dev mode" )
end

function Plugin:Cleanup()

	kLiftEnabled = false 
	self.Enabled = false
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
