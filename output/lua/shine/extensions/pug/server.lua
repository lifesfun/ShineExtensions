local Shine = Shine

local StringFormat = string.format

local FixArray = table.FixArray
local Count = table.Count
local ChooseRandom = table.ChooseRandom
local TableEmpty = table.Empty

local GetAllClients = Shine.GetAllClients

local CreateVote = Shine.CreateVote

local Plugin = Plugin

--todo client menu for options
--todo vote 
--command functions
--
--check get owner and client functions 
--save queue on and teams on mapchange
--
--todo pause
--todo sub vote + process
	---1.0
	
--tournamentmode
	--status bar of gamestate
--pregame mods and ff on pregame tournamentmode ready options
--
--multirounds
--add native afking and other plugins
--address conflicting mods
--
--check if works with anti - teamstack mod
--active configuration of server

Plugin.Version = "0.8"
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
function Plugin:StartGame()

	local GameRules = GetGamerules()

	self.Pug = false
	TableEmpty( self.Captains )

	local Clients = GetAllClients()

	--resetgamestate
	for Key , Value in pairs( Clients ) do 

		local Team = self.Teams[ Key ] 		
		if not Team then Team = 0 end

		local Player = Value:GetControllingPlayer() 
		GameRules:JoinTeam( Player , Team  , true ) 
	end
end

---queued players can move freely from spec to ready room on game start
function Plugin:JoinTeam( Gamerules , Player , NewTeam , Force )

	if self.Pug == true then return NewTeam end
	if Force == true then return NewTeam end	
	
	--can join spec or readyroom if not a match player
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

--------------------------------Queuefunctions 
function Plugin:AddToQueue( Client ) 

	local Position = #self.Queue + 1  

	self.Queue[ Position ] = Client
	self:QueueStatus( Client , Position )
end

function Plugin:RemoveFromQueue( Client ) 

	for Position, Value in pairs( self.Queue ) do

		if Value == Client then 
		
			self.Queue[ Position ] = nil
			FixArray( self.Queue )
			self:NotifyQueue()
		end
	end
end

function Plugin:NotifyQueue()

	for Position , Client in pairs( self.Queue ) do

		self:QueueStatus( Client , Position )
	end
end

function Plugin:QueueStatus( Client , Position  )

	self:Notify( Client , "You are %s in for the queue for the next round." , true , Position )	
end

-----------------------------Connect Functions 
function Plugin:OnPug( Client )	

	self:AddToQueue( Client )

	local TeamSize = Count( self.Teams ) 
	local MatchSize =  self.Config.TeamSize * 2

	if not TeamSize or TeamSize < MatchSize then

		self:AddNextPlayer( Client ) 
		self:PugStatus()

	elseif TeamSize >= MatchSize and self.Vote = nil and self.Captains == nil then 

		self:CaptainsVote()
	end
end

function Plugin:PugStatus()

	local MatchSize =  self.Config.TeamSize * 2
	local TeamSize = Count( self.Teams ) 

	if not TeamSize or TeamSize >= MatchSize then return end

	local Size = MatchSize - TeamSize 

	self:Notify( nil , "%s more people needed for the pug" , true ,  Size )
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
		self:AddNextPlayer()
		self:PugStatus()

	elseif self.Teams[ Client ] then 
	
		self:Teams[ Client ] = nil 
		self:AddNextPlayer()
		self:PugStatus()
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

function Plugin:AddNextPlayer()

	local Client = self.Queue[ 1 ]   
	if not Client then return end

	self:Teams[ Client ] = 0
	self.Queue[ 1 ] = nil
	FixArray( self.Queue )
end

----------Pick up game progression for team formation 
function Plugin:CaptainsVote()

	if not Count( self.Captains ) >= 4 then self:PickTeam() return end

	if self:HavePlayers == false then return end

	self:ClearCaptains()
	self:ClearTeams()

	self:StartVote()
end

function Plugin:HavePlayers()

	local TeamSize = Count( self.Teams ) 
	local MatchSize =  self.Config.TeamSize * 2
	if TeamSize and TeamSize >= MatchSize then return end
	return false
end

function Plugin:ClearCaptains()
	--clear vote
	self.Captains = nil
end

function Plugin:ClearTeams()

	for Key , Value in pairs( self.Teams ) do self.Teams[ Key ] = 0 end
end

function Plugin:StartVote()

	self:Notify( nil , "Captains Vote has begun!" )

	local Clients = self:GetTeam( 0 )
	
	for Key , Value in pairs( Clients ) do

		self:Notify( Value , "Open your menu to vote" )	
	end

	--setup a vote for each player 
	--networkvar players  to clients 
	--local Vote = CreateVote( nil , nil , nil ) 
	
	self:SimpleTimer( self.Config.VoteTimeout , self:SetCaptains )
end

function Plugin:SetCaptains() 

	local CaptainOne , local CaptainTwo = self:GetCaptains() 
	if not CaptainOne then CaptainOne , CaptainTwo = self:GetRandomCaptain() end
	if not CaptainTwo then CaptainOne , CaptainTwo = self:GetRandomCaptain() end

	self.SetFirstPick( CaptainOne , CaptainTwo )
	self.NotifyCaptains()
end

function Plugin:GetRandomCaptain()
	
	local Clients = self.Teams
	local CurrentCaptain = self.Captain[ 1 ] 
	local OtherCaptain = self.Captain[ 2 ] 

	--if captain cannot be randomed
	if CurrentCaptain then self.Clients[ CurrentCaptain  ] = nil end
	if OtherCaptain then self.Clients[ OtherCaptain ] = nil end

	local Client , local Team = ChooseRandom( Clients ) 
	return Client 
end
			
function Plugin:SetFirstPick( CaptainOne , CaptainTwo )

	--set aliens to first pick
	self.Teams[ CaptainOne ] = 2
	self.Teams[ CapatinTwo ] = 1
		
	--give one pick to alien captain
	self.Captains[ CaptainOne ] = 1
	self.Captains[ CaptainOne ] = 0
end

function Plugin:NotifyCaptain()

	local Team = self:GetTeam( 0 )	
	--networkvar Clients 
	--
	local Captain = self.Captains[ 1 ] 

	self:Notify( Captain , "You are the current captain" )	
	self:Notify( Captain , "It is time to pick your team" )	
	self:Notify( Captain , "Open your menu to vote" )	

	self:SimpleTimer( self.Config.PickTimeout , function() 
	
		--if no choice then 
		local Team = self.Teams[ Client ]  

		local GameRules = GetGamerules()

		local Client = ChooseRandom( Team )
		local Player = Client:GetControllingPlayer()

		GameRules:JoinTeam( Player , Team , true )
		self:CaptainPicked()
	end )
end

function Plugin:CaptainPicked()

	local CurrentCaptain = self.Captains[ 1 ]
	local OtherCaptain = self.Captains[ 2 ]
	
	self.Captains[ CurrentCaptain ] = self.Captains[ CurrentCaptain ] - 1
	if self.Captains[ Client ] <= 0 then self:ChangeCaptains( OtherCaptain , CurrentCaptain ) end

	local TeamSize = self.Config.TeamSize

	if self:CountTeam( 1 ) >= TeamSize and self:CountTeam( 2 ) >= TeamSize then self:StartGame()return end

	self:NotifyCaptain() 
end

function Plugin:ChangeCaptains( CurrentCaptain , OtherCaptain )

	--set captain Current and Other 
	self.Captains[ 1 ] = CurrentCaptain 
	self.Captains[ 2 ] = OtherCaptain

	--give two turns
	self.Captains[ CaptainOne] = 2
	self.Captains[ CaptainTwo] = 0
end

-----------------subing function
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
