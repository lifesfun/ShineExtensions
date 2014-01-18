local Shine = Shine

local StringFormat = string.format
local FixArray = table.FixArray
local Count = table.Count
local TableEmpty = table.Empty

local GetAllClients = Shine.GetAllClients
local GetClient = Shine.GetClient

local CreateVote = Shine.CreateVote
local Plugin = Plugin

--todo vote capt
--todo client menu for options
--todo pause
--todo sub vote + process
--save queue on and teams on mapchange
--check get owner and client functions 
--reset game + start game +captains etc
--1.0
-- 
--multirounds
--check if works with anti - teamstack mod
--hooks for start round and disabling of readyroom
--status bar of gamestate
--pregame mods and ff on pregame tournamentmode ready options
--add native afking and other plugins

Plugin.Version = "1.0"
Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = { 

	TeamSize = 6,
	PugMessage = 2,
	VoteTimeout = 30,
	PickTimeout = 20,
	SubTimeout = 30
}

Plugin.CheckConfig = true
Plugin.DefaultState = true

Plugin.Captains = {}
Plugin.Queue = {}
Plugin.Teams = {}
Plugin.Vote = {} 

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
--Useful AddOns:  afkkick , pregame( plus , tournamentmode , shine/mode )
--Possible Confilics: readyroom?   
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

---queued players can move freely from spec to ready room on game start
function Plugin:JoinTeam( Gamerules , Player , NewTeam , Force )

	if self.Pug == true then return NewTeam end
	if Force == true then return NewTeam end	
	
	--can joint kpec or readyroom if not a match player
	local Client = Player:GetOwner()
	local Team = self.Teams[ Client ]
	if NewTeam == 0 or 3 and not Team then return NewTeam end 
	return false
end

function Plugin:ClientConfirmConnect( Client )

	if self.Pugs == true then self:OnPug( Client ) end	
	if self.Pugs == false then self:OnGame( Client ) end 

	self:SimpleTimer( self.Config.PugMessage , function()

		self:Notify( Client , "Pug mode is Enabled.") 
		self:Notify( Client , "Are you ready to PUeegh?!" ) 
	end ) 
end

function Plugin:ClientDisconnect( Client ) 

	if self.Pug == true then self:OnPugLeave( Client ) return end
	self:OnGameLeave( Client )  
end

--todo add queue status?
-----------------------------Connect Functions 
function Plugin:OnPug( Client )	

	self:AddToQueue( Client )

	local TeamSize = Count( self.Teams ) 
	local MatchSize =  self.Config.TeamSize * 2

	if not TeamSize or TeamSize < MatchSize then

		local Size = MatchSize - TeamSize 
		self:AddPlayer( Client ) 
		self:Notify( nil , "%s more people needed to start the pug" , true ,  Size )
	
	elseif self.pug == true and self.Captains == nil and TeamSize >= MatchSize and self.Vote = nil then 

		self:StartVote()
	end
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
	--if captains leaves then reset team pick and captains vote
	--if player leaves reset team pick
function Plugin:OnPugLeave( Client )

	if self.Captain[ Client ] then
			
		self.Teams[ Client ] = nil 
		self:AddPlayer()
		self:ClearCaptains()
		self:ClearTeams()

		self.CaptainsVote()

	elseif self.Teams[ Client ] then 
	
		self:Teams[ Client ] = nil 
		self:AddPlayer()
		self:ClearTeams()

		self:PickTeams()
	else
		self:RemoveFromQueue( Client )	
	end
end
	--if player then pause game and call sub vote
function Plugin:OnGameLeave( Client )

	local Team = self.Teams[ Client ]

	if Team then 

		local ClientID = Client:GetUserId()
		self.Teams[ Client ] = nil
		self.Teams[ ClientID ] = Team 
		-- pause
		self:GetSub()
	else
		self:RemoveFromQueue( Client ) 
	end
end

function Plugin:AddPlayer()

	local Client = self.Queue[ 1 ]   
	if not Client then return end

	self:Teams[ Client ] = 0
	self.Queue[ 1 ] = nil
	FixArray( self.Queue )
end

function Plugin:ClearCaptains()
	--clear vote
	self.Captains = nil
end

function Plugin:ClearTeams()

	for Key , Value in pairs( self.Teams ) do self.Teams[ Key ] = 0 end
end


--------------------------------Queuefunctions 
function Plugin:AddToQueue( Client ) 

	self.Queue[ #self.Queue + 1 ] = Client
end

function Plugin:RemoveFromQueue( Client ) 

	for Key , Value in pairs( self.Queue ) do

		if Value == Client then 
		
			self.Queue[ Key ] = nil
			FixArray( self.Queue )
		end
	end
end


----------Pick up game progression for team formation 
function Plugin:CaptainsVote()

	self:ClearCaptains()
	self:ClearTeams()

	self:Notify( nil , "Captains Vote has begun!" )

	local Clients = self:GetTeam( 0 )
	
	for Key , Value in pairs( Clients ) do

		self:Notify( Value , "Open your menu to vote" )	
	end

	--setup a vote for each player 
	--local Vote = CreateVote( nil , nil , nil ) 
	--self.Config.VoteTimeout 
	--function for timeout
	--
	--networkvar players  to clients 
	
	--if no votes then random players to captains
	
	--get captain results
	--random 2 winners to team 
	--self.Teams[ Client ] = 1
	--self.Teams[ Client ] = 2
	--
	--set first pick 
	--self.Captain[ Client ] = 0
	--self.Captain[ Client ] = 2
	
	for Key , Value in pairs( self.Queue ) do

		self:Notify( Value , "You are %s in for the queue" , true , Key )	
	end
end

function Plugin:PickTeams()

	self:ClearTeams()

	self:Notify( Value , "You are the current captian" )	
	self:Notify( Value , "It is time to pick your team" )	
	self:Notify( Value , "Open your menu to vote" )	

--add seperate function for loop	
	local Team = self:GetTeam( 0 )	
	--networkvar Clients 
	
	--check team size  and other == then startgame 
	--algo 2211
	--if self.captain > 0 then
	
		--prompt self.captain >  0
		--self.Capatin = self.Captain - 1 
	
	--elseif self.captain ==  0
		--other self.Captain == 2
		--prompt 
	--end
	--
	--set timeout furnction 
	--if no choice then random player 
end

function Plugin:GetSub()
	--add a delay option 
	--setup a vote for each player 
	--local Vote = CreateVote( nil , nil , nil ) 
	--self.Config.VoteTimeout 
	--function for timeout
	--
	--networkvar players  to clients 
	--local Vote = CreateVote( nil , nil , nil ) 

end

-----------------------Team and Match Size functions
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

function Plugin:CreateCommands()

	local function VoteCaptain( Client , TargetClient )

		if self.Teams[ Client ] ~= 0 then return end
		if self.Captains then return end
		
		--sendvote to list
	end
	local VoteCaptainCommand = self:BindCommand( "sh_votecapt" , "votecapt" , VoteCaptain , true )
	VoteCaptainCommand:AddParam{ Type = "Client" ,  }
	VoteCaptainCommand:Help( "sh_votecapt PlayerName" )

	local function PickPlayer( Client , TargetClient )

		local Team = self.Teams[ Client ] 
		if self.Captain[ Client ] == 0 then return end

		self.Teams[ TargetClient ]  = Team	
	end
	local PickPlayerCommand = self:BindCommand( "sh_votecapt" , "votecapt" , VoteCaptain , true )
	PickPlayerCommand:AddParam{ Type = "Client" ,  }
	PickPlayerCommand:Help( "sh_votecapt PlayerName" )

	local function StartVote( Client , TargetClient )
	end
	local StartVoteCommand = self:BindCommand( "sh_startvote" , "startvote" , StartVote, false )
	StartVoteCommand:Help( "sh_StartVote" )

	local function Captain( Client , TargetClient )
	end
	local CaptainCommand = self:BindCommand( "sh_captain" , "captain" , Captain , false )
	CaptainCommand:AddParam{ Type = "Client" ,  }
	CaptainCommand:Help( "sh_captain PlayerName" )

	local function Captain( Client , TargetClient )
	end
	local CaptainCommand = self:BindCommand( "sh_captain" , "captain" , Captain , false )
	CaptainCommand:AddParam{ Type = "Client" ,  }

--reset round
--start work with start round?
	local function Start( Client , TargetClient )
	end
	local StartCommand = self:BindCommand( "sh_start" , "start" , Captain , false )
	StartCommand:Help( "sh_captain PlayerName" )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enable = false
end
