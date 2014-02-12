--A mod that provides Lift functions and more!
Script.Load( "lua/Lift.lua" )

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

	Lift.Enabled = self.Config.Default 
	Lift.Dev = self.Config.Dev
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
		self:TellPlayers(  client , Gamerules ) 
	end
end
function Plugin:CheckGameStart( gamerules )

	if gamerules:GetGameStarted() and self.Started == false then 
	
		self:TellPlayers(  nil , gamerules ) 
		self.Started = true
	end
end

function Plugin:TellPlayers( client , gamerules )

	if not Lift or not Lift.Enabled then return end
	if not gamerules:GetGameStarted()  then return end
	self:Notify( client , "I am enabled :D" )
	self:Notify( client , "Press E to use Lift" )
	self:Notify( client , "Gorges can pick up any class, Lerks can pick up Gorges." )
end

function Plugin:CreateCommands()

	local function SetLiftEnabled( client , enable )

		Lift.Enabled = enable 
		self:TellPlayers( nil ) 
	end
	local LiftEnabledCommand = self:BindCommand( "lft" , "lft" , SetLiftEnabled )
	LiftEnabledCommand:AddParam{ Type = "boolean" , Optional = true , Default = true }
	LiftEnabledCommand:Help( "Sets if lift is enabled." )

	local function SetLiftDev( client, enable )

		Lift.Dev = enable 
		self:Notify( nil , "LiftDev is set to %s" , true , enable )	
	end
	local LiftDevCommand = self:BindCommand( "lftdev" , "lftdev" , SetLiftDev )
	LiftDevCommand:AddParam{ Type = "boolean" , Optional = true , Default = false }
	LiftDevCommand:Help( "Sets to  dev mode" )
end

function Plugin:Cleanup()

	Lift.Enabled = nil 
	Lift.Dev = nil
	self.Started = nil
	self.Enabled = false
	self.BaseClass.Cleanup( self )
end

Shine:RegisterExtension( "lift" , Plugin )
