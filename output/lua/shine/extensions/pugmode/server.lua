--[[
Shine Pug Plugin 
Pug - Pick Up Games
	This creates array of players in order to manage the formation of teams.
	Progression:
		Amount needed to be enabled when match size it hit
		Player either ready or become a spectator; else are kicked after the timeout amount
		spectators and non-match players are sent into spectator.
		Captatins are decided after the vote timeout 

		All players are blocked from switching teams and joining
		Commanders will be random to picking teams and for which team they start 
		aptains then have to decide there players and are limited by the choosetimeout
		Players are picked from the ready room and placed on the same side as the commander
--]]

local Shine = Shine

local Notify = Shared.Message
local StringFormat = string.format
local TableEmpty = table.Empty
local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local GetAllClients = Shine.GetAllClients
local GetClient = Shine.GetClient 
local ChooseRandom = table.ChooseRandom
local Shuffle = table.Shuffle
local GetTeamClients = Shine.GetTeamClients
local GetClientByID = Shine.GetClientByID
local BuildScreenMessage = Shine.BuildScreenMessage
local GetAllPlayers = Shine.GetAllPlayers

local Plugin = Plugin
Plugin.Version = "1.1"

Plugin.HasConfig = true
Plugin.ConfigName = "PugMode.json"

Plugin.Commands = {}

Plugin.DefaultConfig = {

	CountdownTime = 15, --How long should the game wait after team are ready to start?

	TeamSize = 6, --Size of Team
	
	NagInterval = 30, --how often players are Nagged of the game status 

	VoteTimeout = 30, --length for all vote timeouts. Captains vote, Captains Teams, Captains choose

	Rounds = 2

}

Plugin.CheckConfig = true

--Don't allow the afkkick, pregame, mapvote or readyroom plugins to load with us.
Plugin.Conflicts = {
	DisableThem = {
		"pregame",
		"readyroom"
	}
}

Plugin.CountdownTimer = "TournamentCountdown"
Plugin.FiveSecondTimer = "Tournament5SecondCount"
Plugin.GameStatusTimer = "GameStatusInterval" 

function Plugin:Initialise()

	if Shine.GetGamemode() ~= "ns2" then return false end

	self.PugsStarted = false
	self.PickStarted = false
	self.GameStarted = false

	self.Players = {} --player queue for who gets into the pug array is numeric order 
	self.FirstVote = {} 
	self.SecondVote = {}
	self.Captains = {} --If the captain leaves before the teams are chosen the next highist votes player on the team will become captain. 
	self.CurrentCaptain = 0 

	self.Rounds = 0
	self.TeamMembers = {}
	self.ReadyStates = { false , false }
	self.TeamNames = {}
	self.NextReady = {}
	self.TeamScores = { 0, 0 }


	self.dt.MarineScore = 0
	self.dt.AlienScore = 0

	self.dt.AlienName = ""
	self.dt.MarineName = ""

	--We've been reactivated, we can disable autobalance here and now.
	if self.Enabled ~= nil then

		Server.SetConfigSetting( "auto_team_balance", false )
		Server.SetConfigSetting( "end_round_on_team_unbalance", false )
		Server.SetConfigSetting( "force_even_teams_on_join", false )
	end

	self:CreateCommands()
	
	self.Enabled = true

	return true

end

function Plugin:Notify( Player, Message, Format, ... )

	Notify( Player, "[Pug Mode]"..Message, Format, ... )

end

function Plugin:StartPug()

	local MatchSize = self.Config.TeamSize * 2
	local Clients = GetAllClients()
	local Players = Count( Clients )

	if Timer.Exists( self.GameStatusTimer ) == false then

			self:GameStatus()

			return true

		end


	if Players >= MatchSize then 

		self:StartVote() 

		return true
	
	else
		local TeamSize = self.Config.TeamSize 
		local Num = self.Config.TeamSize * 2 
		local Waiting = StringFormat( "Waiting for the Pick up Game to begin for a %s V %s Pug" , TeamSize , TeamSize ) 
		Shine:SendText( nil , Shine.BuildScreenMessage( 2, 0.5, 0.7, Waiting , 5, 255, 255, 255, 1, 3, 1 ) )

		Num = Num - Count( GetAllClients()) 
		self:Notify( nil , "%s more players required to start the Pueegh", true , Num )

	end

	return false

end

function Plugin:StartVote() 

	local Players = GetAllPlayers() 
	local Rounds = self.Config.Rounds

	self.PugsStarted = true	
	self.Rounds = Rounds
	self:CreateTeamMembers() 
	self:GameStatus()

	for Value , Key in pairs( Players ) do

		local Player = Players[ Key ]:GetControllingPlayer()

		Gamerules:JoinTeam( Value , 3 , nil , true ) 

	end

	for Value , Key in pairs( self.TeamMembers ) do

		local Client = GetClientByID( Key ) 
		local Player = Player:GetControllingPlayer() 

		Gamerules:JoinTeam( Value , 0 , nil , true ) 

	end

  
	self:Notify( nil , "Players have %s to vote for the first captain.", true ,  self.Config.VoteTimeout )
	self:Notify( nil , "Use sh_vote1 in console or !vote1 in chat followed by the player name."  )

	Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captain[ 1 ] = self:NewCaptain( self.FirstVote ) 

	end ) 

	self:Notify( nil , "Players have %s to vote for the first captain.", true ,  self.Config.VoteTimeout )
	self:Notify( nil , "Use sh_vote2 in console or !vote2 in chat followed by the player name."  )

	Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captains[ 2 ] = self:NewCaptain( self.SecondVote )

	end ) 

	self:CaptainsTeams()

	return true

end

function Plugin:CreateTeamMembers() 

	local MatchSize = self.Config.TeamSize * 2

	local function MakeMatchPlayer( ID )

		local Client = GetClientByID( ID ) 

		if Client ~= nil then

			self.TeamMembers[ ID ] = 0 	

			return true 

		end

		return false

	end 

	for Key , Value in ipairs( self.Players ) do 	
			
		if Count( self.TeamMembers ) >= MatchSize then 

			FixArray( self.Players )  

			return true

		end

		self:MakeMatchPlayer( Value )
		self.Players[ Key ] = nil

	end

	FixArray( self.Players )  

	return false
		
end

--[[
	Rejoin a reconnected client to their old team.
]]
function Plugin:ClientConnect( Client )
		
	if Client:GetIsVirtual() == true then return end

	local ID = Client:GetUserId() 
	local PugsStarted = self.PugsStarted
	local GameStarted = self.GameStarted

	local PlayerExist = function( ID ) 

		for Key, Value in ipairs( self.Players ) do 	

			if Value == ID then
				
				return true
			end

		end

		Players[ #Players + 1 ] = ID
		
		return false
		
	end

	if self.GameStarted == true then 

		self:NeedSubs() 

		if self.TeamMembers[ ID ] then

			Gamerules:JoinTeam( Client:GetControllingPlayer(), self.TeamMembers[ ID ], nil, true )     


		end

		return true

	elseif self.PugsStarted == true then

		Gamerules:JoinTeam( Client:GetControllingPlayer() , 3 , nil , true )
		
		return true

	elseif self.PugsStarted == false and self.GameStarted == false then 
	
		self:StartPug() 
		
		return true

	end

	
	return false

end

function Plugin:ClientDisconnect( Client ) 

	local ID = Client:GetUserId() 

	if self.GameStarted == true then 
	
		self:NeedSub() 

		return true

	elseif self.PugsStarted == true and self.GameStarted == false then

		if self.Captains[ 1 ] == ID or self.Captains[ 2 ] == ID then

			self:ReplaceCaptain( ID )
			
		end

		return true

	end
	
	return false

end

function Plugin:VoteOne( Client , Vote )

	if self.GameStarted == true or self.PugsStarted == false then return false end

	if not Client then return end	

	local ID = Client:GetUserId()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.TeamMembers[ ID ] == true and PlayerClient ~= nil and self.SecondVote[ ID ] == Vote then	

		self:Notify( Client, "You have voted for %s !", true,  PlayerName ) 
	
		return true 
	end 
	
	return false

end

function Plugin:VoteTwo( Client , Vote )
	
	if self.GameStarted == false or self.PugsStarted == false then return false end

	if not Client then return end	

	local ID = Client:GetUserId()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.TeamMembers[ ID ] == true and PlayerClient ~= nil and self.FirstVote[ ID ] == Vote then	

		self:Notify( Client, "You have voted for %s !", true , PlayerName ) 
	
		return true 
	end 
	
	return false

end

function Plugin:NewCaptain( VoteList ) 

	local TopVoted = 0
	local Captain = nil

	local function GetCount( VoteID , VoteList )
		
		for Key , Value in pairs( VoteList ) do

			local Count = 0

			if Value == VoteID then 
				
				Count = Count + 1

			end
				
		end

		return Count

	end

	for Key , Value in pairs( self.TeamMembers ) do

		local Client = GetClientByID( Key )	
		local Count = GetCount( Value , VoteList )

		if Client ~= nil and Key ~= self.Captains[ 1 ] or self.Captains[ 2 ] and Count >= TopVoted then 

			TopVoted = Count
			Captain = Key 

		end
	end

	return Captain

end

function Plugin:ReplaceCaptain( ID ) 

	local Team = self.TeamMembers[ ID ] 
	local Captain = nil
	local Votes = {}

	for Key , Value in pairs( self.FirstVote ) do	
		
		if TeamMembers[ Value ] == Team then 

			Votes[ Key ] = Value

		end

	end

	for Key , Value in pairs( self.SecondVote ) do	
		
		if TeamMembers[ Value] == Team and Votes[ Key ] == nil then 

			Votes[ Key ] = Value

		end

	end
		
	Captain = self.NewCaptain( Votes )

	local Client = GetUserByID( Captain ) 	
	local PlayerName = Client:GetControlllingPlayer():GetName() 

	Gamerules:JoinTeam( Client , Team , nil , true ) 

	self.Captains[ Team ] = Captain
	self:PickPlayer() 

	self:Notify( nil , "One of the captains has left the game. %s is the new captain." , true , PlayerName )

	return true

end

function Plugin:JoinTeam( Gamerules , Player , NewTeam , Force ) 

	if self.GameStarted == true and NewTeam == 0 then return 0 elseif NewTeam == 3 then return 3 end
	if PugsStarted == true then return false end 

	return NewTeam

end
--[[
	Record the team that players join.
]]
function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force )
	
	local Client = Server.GetOwner( Player )

	if not Client then return end

	local ID = Client:GetUserId()

	if self.PickStarted == true then 
	
		self.TeamMembers[ ID ] = NewTeam

	end

	return false
end


function Plugin:CaptainsTeams()	

	local Player = {}
	local CaptainOne = GetClientByID( self.Captains[ 1 ] )
	local CaptainTwo = GetClientByID( self.Captains[ 2 ] )

	Player[ 1 ] = CaptainOne:GetControllingPlayer() 
	Player[ 2 ] = CaptainTwo:GetControllingPlayer() 

	Shuffle( self.Captains )
	Shuffle( Player )

	Gamerules:JoinTeam( Player[ 1 ] , 1 , nil , true ) 
	Gamerules:JoinTeam( Player[ 2 ] , 2 , nil , true ) 

	self:PickTeams() 
	
end

function Plugin:PickTeams()

	self.PickStarted = true
	self:GameStatus()

	while Count( shine.GetTeamClients( 0 ) ) ~= 0 do

		self:Notify( Captain , "You have %s unitl a player is randomed to your team.", true , self.Config.VoteTimeout )

		self:PickPlayer()

	end

	self.GameStarted = true
	self:GameStatus()

	return true

end
	
function Plugin:PickPlayer()

	local Captain = GetUserByID( self.CurrentCaptain ) 

	self:Notify( Captain , "It is now your turn to pick!" ) 
	self:Notify( Captain , "Use sh_choose in console or !choose in chat followed by a players name." ) 

	Timer.Simple( self.Config.VoteTimeout , function() 
		
		local Value , Key = ChooseRandom( GetTeamClients( 0 ) ) 
		local Client = GetClientByID( self.CurrentCaptain )

		self:Choose( Client , Value ) 
		self:CurrentPick()

	end )  

	return true
	
end

function Plugin:CurrentPick()

	local CaptainOne = GetClientByID( self.Captain[ 1 ] )
	local CaptainTwo = GetClientByID( self.Captain[ 2 ] )
	local PlayerOne = CaptainOne:GetControllingPlayer()  
	local PlayerTwo = CaptainTwo:GetControllingPlayer()  
	local TeamOne = PlayerOne:GetTeamSize()
	local TeamTwo = PlayerTwo:GetTeamSize()
	local MaxSize = self.Config.TeamSize
	local Captain = nil

	if TeamOne < TeamTwo and SizeOne < MaxSize then 

			self.CurrentCaptain = CaptainOne 

		return true

	elseif TeamOne < TeamTwo and SizeTwo < MaxSize then

			self.CurrentCaptain = CaptainTwo
		
		return true

	end
	
	return false

end

function Plugin:Choose( Client , PlayerID )

	if self.PickStarted == false then return false end

	if not Client then return end	

	local ID = Client:GetUserId()
	local PlayerClient = GetClient( PlayerID ) 
	local Player = PlayerClient:GetControllingPlayer()  
	local Team = Player:GetTeamNumber()

	if ID == self.CurrentCaptain and PlayerClient ~= nil then
		
		Gamerules:JoinTeam( Player , Team , nil , true ) 

		self:Notify( Client , "Nice choice.. or hopefully it was. Please wait for your next turn." )

		self:PickTeams() 

		return true
		
	elseif Captain ~= ID then 

		self:Notify( Client, "You are not the current Captain." )

	end 

	return false

end

function Plugin:GetTeamName( Team )

	if self.TeamNames[ Team ] then

		return self.TeamNames[ Team ]

	end

	return Shine:GetTeamName( Team, true )

end

function Plugin:GetReadyState( Team )

	return self.ReadyStates[ Team ]

end

function Plugin:GetOppositeTeam( Team )

	return Team == 1 and 2 or 1

end

function Plugin:CheckStart()

	--Both teams are ready, start the countdown.
	if self.ReadyStates[ 1 ] and self.ReadyStates[ 2 ] then

		local CountdownTime = self.Config.CountdownTime

		local GameStartTime = string.TimeToString( CountdownTime )

		Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Game starts in "..GameStartTime, 5, 255, 255, 255, 1, 3, 1 ) )

		--Game starts in 5 seconds!
		Timer.Create( self.FiveSecondTimer, CountdownTime - 5, 1, function()

			Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Game starts in %s", 5, 255, 0, 0, 1, 3, 0 ) )
		end )

		--If we get this far, then we can start.
		Timer.Create( self.CountdownTimer, self.Config.CountdownTime, 1, function()

			self:StartGame()

		end )

		return


	--One or both teams are not ready, halt the countdown.
	elseif Timer.Exists( self.CountdownTimer ) then

		Timer.Destroy( self.FiveSecondTimer )
		Timer.Destroy( self.CountdownTimer )

		--Remove the countdown text.
		Shine:RemoveText( nil, { ID = 2 } )

		self:Notify( nil, "Game start aborted." )

	end

end

function Plugin:RemovePlayer( Team )
	
	for Key , Value in ipairs( self.Players ) do

		local Client = GetClientByID( Value )
		local Player = Client:GetControllingPlayer()
		local PlayerName = Player:GetName()

		if Player:GetTeamNumber() == Team then

			Gamerules:JoinTeam( Player , 3 , nil , true ) 
			self:Notify( nil , "A team member has joined the game. The sub %s is being moved to spectator.", true ,  PlayerName )

			return true

		end

	end

	return false

end

function Plugin:AddPlayer( Team )

	local PlayerName = nil
	
	for Key , Value in ipairs( self.Players ) do

		local Client = GetClientByID( Value )
		local Player = Client:GetControllingPlayer()
		local PlayerName = Player:GetName() 

		if Player:GetTeamNumber() == 0 or 3 then

			Gamerules:JoinTeam( Player , Team , nil , true ) 

			self:Notify( nil , "A team member has left the game. The sub %s is the being substituted.", true , PlayerName )

			return true

		end

	end

	return false

end

function Plugin:NeedSub()

	local TeamSize = self.Config.TeamSize

	local TeamOne = Count( GetTeamClients( 1 ) ) 
	local TeamTwo = Count( GetTeamClients( 2 ) ) 

	if TeamOne > TeamSize and self.RemovePlayer( 1 ) == false then	

		return false

	elseif TeamOne < TeamSize and self.AddPlayer( 1 ) == false then

		return false
	end

	if TeamTwo > TeamSize and self.RemovePlayer( 2 ) == false then	

		return false

	elseif TeamTwo < TeamSize and self.AddPlayer( 2 ) == false then	

		return false

	end 

	if TeamSize ~= TeamOne and TeamTwo then

		self:NeedSub()

	end

	return true
end

function Plugin:GameStatus() 

	local Pugs = self.PugsStarted
	local Pick = self.PickStarted
	local Game = self.GameStarted

	if Timer.Exists( self.GameStatusTimer ) == true then
	
		Shine:RemoveText( nil, { ID = 50 } )
		Timer.Destroy( self.GameStatusTimer )

	end

	Timer.Create( self.GameStatusTimer , self.Config.NagInterval , 1 , self:GameStatus() )  

	if Pugs == true and Pick == false then
	
		Shine:SendText( nil, BuildScreenMessage( 50 , 0.5, 0.7, "Time to vote for captains", 5, 255, 255, 255, 1, 3, 1 ) )

	elseif Pick == true and Game == false then 

		Shine:SendText( nil, BuildScreenMessage( 50 , 0.5, 0.7, "Captains are now picking teams" , 5, 255, 255, 255, 1, 3, 1 ) )
	elseif Game == true then

		local Nag = self:GetStartNag()

		if not Nag then return false end

		self:SendNetworkMessage( nil, "StartNag", { Message = Nag }, true )

	end

	return false
		
end

function Plugin:GetStartNag()

	local MarinesReady = self.ReadyStates[ 1 ]
	local AliensReady = self.ReadyStates[ 2 ]

	if MarinesReady and AliensReady then return nil end
	
	if MarinesReady and not AliensReady then

		return StringFormat( "Waiting on %s to start", self:GetTeamName( 2 ) )

	elseif AliensReady and not MarinesReady then

		return StringFormat( "Waiting on %s to start", self:GetTeamName( 1 ) )
		
	else

		return StringFormat( "Waiting on both teams to start" )

	end

end

function Plugin:CommLogout( Gamerules )

--not sure if this works?
	if self.PugsStarted == false or self.GameStarted == false then return end

	local Team1 = Gamerules.team1
	local Team2 = Gamerules.team2

	local Team1Com = Team1:GetCommander()
	local Team2Com = Team2:GetCommander()

	local MarinesReady = self.ReadyStates[ 1 ]
	local AliensReady = self.ReadyStates[ 2 ]

	if MarinesReady and not Team1Com then

		self.ReadyStates[ 1 ] = false

		self:Notify( nil, "%s is no longer ready. A commander is required.", true, self:GetTeamName( 1 ) )

		self:CheckStart()
	end

	if AliensReady and not Team2Com then

		self.ReadyStates[ 2 ] = false

		self:Notify( nil, "%s is no longer ready. A commander is required.", true, self:GetTeamName( 2 ) )

		self:CheckStart()
	end

end

function Plugin:StartGame()

	local Gamerules = GetGamerules() 	

	if Timer.Exists( self.GameStatusTimer ) == false then

		Timer.Destroy( self.GameStatusTimer ) 
		Shine:RemoveText( nil, { ID = 50 } )

	end

	self.CurrentCaptain = nil
	self.PugsStarted = false
	self.PickStarted = false

	Gamerules:ResetGame()
	Gamerules:SetGameState( kGameState.Countdown )
	Gamerules.countdownTime = kCountDownLength
	Gamerules.lastCountdownPlayed = nil

	for _, Player in ientitylist( Shared.GetEntitiesWithClassname( "Player" ) ) do

		if Player.ResetScores then

			Player:ResetScores()

		end

	end

	TableEmpty( self.ReadyStates )
	TableEmpty( self.Captains )
	TableEmpty( self.FirstVote ) 
	TableEmpty( self.SecondVote )

end

function Plugin:EndGame( Gamerules , WinningTeam ) 

	local RoundsLeft = self.Rounds

	if RoundsLeft ~= 0 and self.GameStarted == true then
		
		self.Rounds = RoundsLeft - 1

		for Key , Value in pairs( self.TeamMembers ) do
			
			self.TeamMembers[ Key ] = GetOppositeTeam( Value )	

			local Client = GetClientByID( Key ) 	

			if Client ~= nil then return end
	
			Gamerules:JoinTeam( Client:GetControllingPlayer(), self.TeamMembers[ Key ], nil, true )     
		end
	
	elseif RoundsLeft == 0 then 	
	
		for Key , Value in pairs( self.TeamMembers ) do
			
			self.Players[ #Players + 1 ] = Key  
		
		end
		
		 
		 TableEmpty( self.TeamMembers )
		 self.GameStarted = false
		 self:StartPug()

	
	end
	--changemap? save player queue 
	
end

function Plugin:CreateCommands()

	local function ReadyUp( Client )

		if self.GameStarted == false then return end

		local Player = Client:GetControllingPlayer()

		if not Player then return end
		
		local Team = Player:GetTeamNumber()

		if Team ~= 1 and Team ~= 2 then return end

		if not Player:isa( "Commander" ) then

			self:Notify( Client, "Only the commander can ready up the team." )

			return
		end

		local Time = Shared.GetTime()

		local NextReady = self.NextReady[ Team ] or 0

		if not self.ReadyStates[ Team ] then

			if NextReady > Time then return end

			self.ReadyStates[ Team ] = true

			local TeamName = self:GetTeamName( Team )

			local OtherTeam = self:GetOppositeTeam( Team )
			local OtherReady = self:GetReadyState( OtherTeam )

			if OtherReady then

				self:Notify( nil, "%s is now ready.", true, TeamName )

			else

				self:Notify( nil, "%s is now ready. Waiting on %s to start.", true, TeamName, self:GetTeamName( OtherTeam ) )
			end
			
			--Add a delay to prevent ready->unready spam.
			self.NextReady[ Team ] = Time + 5

			self:CheckStart()
		else

			self:Notify( Client, "Your team is already ready! Use !unready to unready your team." )

		end

	end

	local ReadyCommand = self:BindCommand( "sh_ready", { "rdy", "ready" }, ReadyUp, true )
	ReadyCommand:Help( "Makes your team ready to start the game." )
	
	local function Unready( Client )

		if self.GameStarted == false then return end

		local Player = Client:GetControllingPlayer()

		if not Player then return end
		
		local Team = Player:GetTeamNumber()

		if Team ~= 1 and Team ~= 2 then return end

		if not Player:isa( "Commander" ) then

			self:Notify( Client, "Only the commander can ready up the team." )

			return
		end

		local Time = Shared.GetTime()

		local NextReady = self.NextReady[ Team ] or 0

		if self.ReadyStates[ Team ] then

			if NextReady > Time then return end

			self.ReadyStates[ Team ] = false

			local TeamName = self:GetTeamName( Team )

			self:Notify( nil, "%s is no longer ready.", true, TeamName )

			--Add a delay to prevent ready->unready spam.
			self.NextReady[ Team ] = Time + 5

			self:CheckStart()
		else
			self:Notify( Client, "Your team has not readied yet! The commander has to type !ready to ready your team." )
		end
		
	end

	local UnReadyCommand = self:BindCommand( "sh_unready", { "unrdy", "unready" }, Unready, true )
	UnReadyCommand:Help( "Makes your team not ready to start the game." )

	local function SetTeamNames( Client, Marine, Alien )

		self.TeamNames[ 1 ] = Marine
		self.TeamNames[ 2 ] = Alien

		self.dt.MarineName = Marine
		self.dt.AlienName = Alien

	end

	local SetTeamNamesCommand = self:BindCommand( "sh_setteamnames", { "teamnames" }, SetTeamNames )
	SetTeamNamesCommand:AddParam{ Type = "string", Optional = true, Default = "" }
	SetTeamNamesCommand:AddParam{ Type = "string", Optional = true, Default = "" }
	SetTeamNamesCommand:Help( "<Marine Name> <Alien Name> Sets the names of the marine and alien teams." )

	local function SetTeamScores( Client, Marine, Alien )

		self.TeamScores[ 1 ] = Marine
		self.TeamScores[ 2 ] = Alien

		self.dt.MarineScore = Marine
		self.dt.AlienScore = Alien

	end

	local SetTeamScoresCommand = self:BindCommand( "sh_setteamscores", { "scores" }, SetTeamScores )
	SetTeamScoresCommand:AddParam{ Type = "number", Min = 0, Max = 255, Round = true, Optional = true, Default = 0 }
	SetTeamScoresCommand:AddParam{ Type = "number", Min = 0, Max = 255, Round = true, Optional = true, Default = 0 }
	SetTeamScoresCommand:Help( "<Marine Score> <Alien Score> Sets the score for the marine and alien teams." )

	local VoteOneCommand = self:BindCommand( "sh_vote1" , { "vote1" } , self.VoteOne , true )
    	VoteOneCommand:AddParam{ Type = "string" , Default = "" }    


	local VoteTwoCommand = self:BindCommand( "sh_vote2" , { "vote2" } , self.VoteTwo , true )
    	VoteTwoCommand:AddParam{ Type = "string" ,  Default = "" }    
    
	local ChooseCommand = self:BindCommand( "sh_choose" , { "choose" } , self.Choose  , true )
    	ChooseCommand:AddParam{ Type = "string" ,   Default = "" }    

	local StartVoteCommand = self:BindCommand( "sh_startvote" , { "startvote" } , self.StartVote )

	local StartGameCommand = self:BindCommand( "sh_startgame" , { "startgame" } , self.StartGame )

	--unbockteams


end

function Plugin:Cleanup()

	TableEmpty( self.FirstVote  ) 
	TableEmpty( self.SecondVote ) 

	TableEmpty( self.TeamMembers ) 
	TableEmpty( self.ReadyStates ) 
	TableEmpty( self.TeamNames ) 

	Server.SetConfigSetting( "auto_team_balance", true )
	Server.SetConfigSetting( "end_round_on_team_unbalance", true )
	Server.SetConfigSetting( "force_even_teams_on_join", true )

	self.Enabled = false

	self.BaseClass.Cleanup( self )
end

