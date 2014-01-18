local Shine = Shine

local StringFormat = string.format
local FixArray = table.FixArray
local Count = table.Count
local TableEmpty = table.Empty

local GetAllClients = Shine.GetAllclients
local GetClient = Shine.GetClient
local GetTeamClients = Shine.GetTeamClients
local GetAllPlayers = Shine.GetAllPlayers

local Plugin = Plugin

Plugin.Version = "1.0"
Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = { 
	TeamSize = 6
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

Plugin.Captains = {}
Plugin.Queue = {}
Plugin.Teams = {}

function Plugin:Initialize()

	self:CreateCommands()
	self.Pug == true
	self.Enabled = true

	return true
end

function Plugin:Notify( Player , Message ,Format , ... ) 

	Shine:NotifyDualColour( Client , 0 , 100 , 255 , " PugBot" , 255 , 255 , 255 , String , Format , ... )
end
---------Game does Force players until Teams are Picked

function Plugin:StartGame()

	local GameRules = GetGamerules()

	self.Pug = false
	TableEmpty( self.Captains )

	local Clients = GetAllClients()

	--resetgamestate
	for Key , Value in pairs( Clients ) do 

		local Team = self.Teams[ Value ] 		
		if not Team then Team = 0 end

		local Player = Value:GetControllingPlayer() 
		GameRules:JoinTeam( Player , Team  , true ) 
	end
end

---queued players can move freely form spec to ready room on game start
function Plugin:JoinTeam( Gamerules , Player , NewTeam , Force )

	if self.Pug == true then return NewTeam end
	if Force == true then return NewTeam end	
	
	--can joint spec or readyroom if not a match player
	local Client = Player:GetOwner()
	local Team = self.Teams[ Client ]
	if NewTeam == 0 or 3 and not Team then return NewTeam end 
	return false
end

function Plugin:ClientConfirmConnect( Client )

	if self.Pugs == true then self:OnPug( Client ) end	
	if self.Pugs == false then self:OnGame( Client ) end 

	self:SimpleTimer( 4 , function()

		self:Notify( Client , "Pug mode is Enabled.") 
		self:Notify( Client , "Are you ready to PUeegh?!" ) 
	end ) 
end

function Plugin:ClientDisconnect( Client ) 

	if self.Pug == true then self:OnPugLeave( Client ) end
	if self.Pug == false then self:OnGameLeave( Client ) end 
end

--------Connect Functions 

function Plugin:OnPug( Client )	

	local i = self:CountTeam( 0 )

	if i >= self.MatchSize() then

		self:AddToQueue( Client )
		self.Teams[ Client ] = 3
		self:Startvote()
	else
		self.Teams[ Client ] = 0
		self:Notify( nil , "%s more people needed to start the pug" , true , i + 1 )
	end
	-- if vote started 
		
end

function Plugin:OnGame( Client )

	local ClientID = Client:GetUserId()
	local Team = self.Teams[ ClientID ] 
	local Player = Client:GetControllingPlayer()

	if Team then 

		self.Teams[ ClientID ] = nil
		self.Teams[ Client ] = Team 
		--remove sub
		--if paused then unpause
	else 
		Team = 0 
		self:AddToQueue( Client )
	end

	local GameRules = GetGamerules()
	GameRules:JoinTeam( Player , Team , true )
end

---Disconnect Functions  

function Plugin:OnPugLeave( Client )

	if self.Captain[ Client ] then
			
		self.Teams[ Client ] = nil 
		self:AddPlayer()
		self:ClearCaptains()
		self:ClearTeams()

		self.CaptainsVote()

	elseif self:IsPlayer( Client ) then 
	
		self:Teams[ Client ] = nil 
		self:AddPlayer()
		self:ClearTeams()

		self:PickTeams()
	else
		self:RemoveFromQueue( Client )	
	end
end

----if captains leaves then reset team pick and captains vote
-------if player leaves resett team  pick
function Plugin:OnGameLeave( Client )

	local Team = self.Teams[ Client ]
	if Team then 

		local ClientID = Client:GetUserId()
		self.Teams[ Client ] = nil
		self.Teams[ ClientID ] = Team 
		-- pause
		-- vote for sub end after 30 sec
		--or delay 
	else
		self:RemoveFromQueue( Client ) 
	end
end

function Plugin:ClearCaptains()
	--clear vote
	self.Captains = nil
end

function Plugin:ClearTeams()

	for Key , Value in pairs( self.Teams ) do self.Teams[ Key ] = 0 end
end

----------Pick up game progression for team formation 

function Plugin:CaptainsVote()
	--call a captains reset
	--startvote
	local Team = self:GetTeam()
	--networkvar
	--setcaptain 
	self:Randomplayer( self:Captains )
end

function Plugin:PickTeams()
	--call a teams reset 
	
	self:GetTeam()	
	--networkvar
	--
	--randomplayer
	--
	--set currentcapt
	--2211
	--prompt current captain
end

------------------generic team functions 
function Plugin:MatchSize()

	return self.Config.TeamSize * 2
end

function Plugin:GetTeam( Team ) 

	local Clients = {}
	for Key , Value in pairs( self.Teams ) do

		if Value == Team and not self.Captain[ Key ] then 
			
		end
	end
end

function Plugin:CountTeam( Team ) 
	
	local i = 0 

	for Key , Value in pairs( self.Teams ) do

		if Value == Team then i = i + 1 end
	end

	return i 
end

---------------------queue functions 

function Plugin:AddToQueue( Client ) 

	self.Queue[ #self.Queue + 1 ] = Client
	self.Teams[ Client ] = 3
end

function Plugin:RemoveFromQueue( Client ) 

	for Key , Value in pairs( self.Queue ) do

		if Value == Client then 
		
			self.Queue[ Key ] = nil
			FixArray( self.Queue )
		end
	end
end


-----------------------PlayerFunctions
--3 is queue , 0 is a player w/o a team , 1 marines , 2 aliens 

function Plugin:IsPlayer( Client ) 

	if self:Teams[ Client ] == 1 or 2 or 0 then return true end
end


function Plugin:AddPlayer()

	if not Client then return end
	local Client = self.Queue[ 1 ]   
	self:Teams[ Client ] = 0
	self.Queue[ 1 ] = nil
	FixArray( self.Queue )
end


function Plugin:CreateCommands()

	local function VoteCaptain( Client , TargetClient )
		if self.Teams[ Client ] ~= 0 then return end
		--sendvote to list
	
	end
	local VoteCaptainCommand = self:BindCommand( "sh_votecapt" , "votecapt" , VoteCaptain , true )
	VoteCaptainCommand:AddParam{ Type = "Client" ,  }
	VoteCaptainCommand:Help( "sh_votecapt PlayerName" )

	local function PickPlayer( Client , TargetClient )

		local Team = self.Teams[ Client ] 
		if not self.Captain[ Client ] then return end

		self.Teams[ TargetClient ]  = Team	
		self:PickTeams()
	end
	local PickPlayerCommand = self:BindCommand( "sh_votecapt" , "votecapt" , VoteCaptain , true )
	PickPlayerCommand:AddParam{ Type = "Client" ,  }
	PickPlayerCommand:Help( "sh_votecapt PlayerName" )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enable = false
end
