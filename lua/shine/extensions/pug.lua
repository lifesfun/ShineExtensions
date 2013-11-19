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
		Captains then have to decide there players and are limited by the choosetimeout
		Players are picked from the ready room and placed on the same side as the commander
--]]

local Shine = Shine

local StringFormat = string.format
local TableEmpty = table.Empty
local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message
local GetAllClients = Shine.GetAllClients
local GetClient = Shine.GetClient 
local ChoseRandom = table.ChooseRandom

local Plugin = Plugin
Plugin.Version = "0.98"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"
Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	CountdownTime = 15, --How long should the game wait after team are ready to start?

	TeamSize = 6, --Size of Team
	
	NagInterval = 0.3, --how often players are Nagged of the game status 

	VoteTimeout = 0.5, --length for all vote timeouts. Captains vote, Captains Teams, Captains choose

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

--List of mods not compatible with tournament mode
local BlacklistMods = {
	[ "5f35045" ] = "Combat",
	[ "7e64c1a" ] = "Xenoswarm",
	[ "7957667" ] = "Marine vs Marine",
	[ "6ed01f8" ] = "The Faded"
}

function Plugin:Initialise()

	local GetMod = Server.GetActiveModId

	for i = 1, Server.GetNumActiveMods() do
		local Mod = GetMod( i ):lower()

		local OnBlacklist = BlacklistMods[ Mod ]

		if OnBlacklist then
			return false, StringFormat( "The tournamentmode plugin does not work with %s.", OnBlacklist )
		end
	end

	self.PugsStarted = false
	self.GameStarted = false

	self.Players = {} --player queue for who gets into the pug array is numeric order 
	self.MatchPlayers = {} --list of match players, in case of disconnect the next player on queue subs in; parameters are there captain votes
	--If the captain leaves before the teams are chosen the next highist votes player on the team will become captain. 
	self.FirstVote = {} 
	self.SecondVote = {}
	self.Captain = {}  
	self.CurrentCaptain = nil

	self.TeamMembers = {}
	self.ReadyStates = { false, false }
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
	self:StartPug()
	self:GameStatus()


	self.Enabled = true

	Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Pick Up Game Mode Now Enabled!", 5, 255, 255, 255, 1, 3, 1 ) )

	self:GameStatus()


	return true
end

function Plugin:GameStatus() 

	local PugsStarted = self.PugsStarted 

	self:Timer.Simple( self.Config.NagInterval , function() 

		if PugsStarted == false then

			local Num = self.Config.TeamSize 

			Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Waiting for the Pick up Game to begin for a "..Num.."V"..Num.."Pug", 5, 255, 255, 255, 1, 3, 1 ) )
			self:GameStatus() 

			return true

		elseif PugsStarted == true and self.CurrentCaptain == nil then

			Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Time to vote for captains", 5, 255, 255, 255, 1, 3, 1 ) )
			self:GameStatus() 

			return true

		elseif self.CurrentCaptain ~= nil then

			Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Captains are now picking teams"..GameStartTime, 5, 255, 255, 255, 1, 3, 1 ) )
			self:GameStatus() 

			return true

		end

	end )

end

	--	if stats enabeld add stats to true 
	--	send MatchPlayer to back of the queue
	--

function Plugin:CheckCommanders( Gamerules )

	local Team1 = Gamerules.team1
	local Team2 = Gamerules.team2

	local Team1Com = Team1:GetCommander()
	local Team2Com = Team2:GetCommander()

	local MarinesReady = self.ReadyStates[ 1 ]
	local AliensReady = self.ReadyStates[ 2 ]

	if MarinesReady and not Team1Com then

		self.ReadyStates[ 1 ] = false

		self:Notify( false, nil, "%s is no longer ready.", true, self:GetTeamName( 1 ) )

		self:CheckStart()
	end

	if AliensReady and not Team2Com then

		self.ReadyStates[ 2 ] = false

		self:Notify( false, nil, "%s is no longer ready.", true, self:GetTeamName( 2 ) )

		self:CheckStart()
	end

end

function Plugin:StartGame( Gamerules )

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
	TableEmpty( self.MatchPlayers ) 
	TableEmpty( self.FirstVote ) 
	TableEmpty( self.SecondVote )
	
	self.PugsStarted = true 
	self.CurrentCaptain = nil
	self.GameStarted = true

end

--[[
	Rejoin a reconnected client to their old team.
]]
function Plugin:ClientConfirmConnect( Client )

	if not self.DisabledAutobalance then
	
		Server.SetConfigSetting( "auto_team_balance", false )
		Server.SetConfigSetting( "end_round_on_team_unbalance", false )
		Server.SetConfigSetting( "force_even_teams_on_join", false )

		self.DisabledAutobalance = true

	end
	
	if Client:GetIsVirtual() then return end

	local ID = Client:GetUserId()

	if  self.TeamMembers[ ID ] then

		if GameStarted == true or self.PugsStarted == true then	

			Gamerules:JoinTeam( Client:GetControllingPlayer(), self.TeamMembers[ ID ], nil, true )     

		end
		
	end

end

function Plugin:GetTeamName( Team )

	if self.TeamNames[ Team ] then

		return self.TeamNames[ Team ]

	end

	return Shine:GetTeamName( Team, true )

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

			self:StartGame( GetGamerules() )

		end )

		return
	end

	--One or both teams are not ready, halt the countdown.
	if Timer.Exists( self.CountdownTimer ) then

		Timer.Destroy( self.FiveSecondTimer )
		Timer.Destroy( self.CountdownTimer )

		--Remove the countdown text.
		Shine:RemoveText( nil, { ID = 2 } )

		self:Notify( false, nil, "Game start aborted." )

	end

end

function Plugin:GetReadyState( Team )

	return self.ReadyStates[ Team ]

end

function Plugin:GetOppositeTeam( Team )

	return Team == 1 and 2 or 1

end

function Plugin:ClientConnect( Client )

	local ClientId = Client:GetClientId() 
	
	local PlayerExist = function( ClientId ) 

		for Key, Value in ipairs( self.Players ) do 	

			if Value == ClientId then
				
				return true
			end

		end

		if Players[ #Players + 1 ] = CliendId then
			
			return true
		
		end

		return false

	end

	if self.GameStarted == true and self:CheckSubs() == true then

		return true
	
	elseif self.PugsStarted == true then

		GameRules:JoinTeam( Client:GetControllingPlayer() , 3 , nil , true ) 

		return true
	
	elseif self.PugsStarted == false and self:StartPug() == true then
			
		return true

	elseif self.PugsStarted == false then

		StringFormat( "%s more players required to start the Pueegh", (self.Config.TeamSize * 2) - Count( GetAllClients())  )

	end

	return false


end

function Plugin:ClientDisconnect( Client ) 

	local ClientId = Client:GetUserId() 

	if self.GameStarted == true and self:CheckSubs( Client ) == true then 

		return true

	elseif self.PugsStarted == true and self.MatchPlayers[ GetClientId ] == true then 

			self.MatchPlayers[ ClientId ] = nil
			self:CreateMatchPlayers()

		return true

	end
	
	return false

end

function Plugin:StartPug()

	local MatchSize = self.Config.TeamSize * 2
	local Players = Count( GetallClients() )


	if Players >= MatchSize then 
	
		self:CreateMatchPlayers() 

		self:StartVote() 

		return true
	
	end

	return false

end

function Plugin:CreateMatchPlayers() 

	local MatchSize = self.Config.TeamSize * 2

	local function MakeMatchPlayer( ClientId )

		if Client[ ClientId ] ~= nil then

			self.MatchPlayers[ ClientId ] = 0 	

			return true 

		end

		return false

	end 

	for i , ClientId in ipairs( self.Players ) do 	
			
		if Count( self.MatchPlayers ) >= MatchSize then 

			FixArray( self.MatchPlayers )  

			return true

		end

		self:MakeMatchPlayer( ClientId )
		self.Players[ i ] = nil

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



function Plugin:StartVote() 
--notify vote started
	local Players = Shine.GetAllPlayers 
	
	self.PugsStarted = true  

	for Value , Key in pairs( Players ) do

		Player = Value:GetControllingPlayer()
		GameRules:JoinTeam(  , 3 , nil , true ) 

	end

	for Value , Key in pairs( self.MatchPlayers ) do

		Player = GetClient( Key ) 
		Player = Player:GetControllingPlayer() 

		GameRules:JoinTeam( Player , 0 , nil , true ) 

	end


	StringFormat( "Players have %s to vote for the first captain.", self.Config.VoteTimeout )
	Shine:Notify( Client, "", "", "Use sh_vote1 in console or !vote1 in chat followed by the player name.")

	self:Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captain[ 1 ] = self:NewCaptain( self.FirstVoted ) 

	end ) 

	StringFormat( "Players have %s to vote for the second captain captain.", self.Config.VoteTimeout )
	Shine:Notify( Client, "", "", "Use sh_vote1 in console or !vote1 in chat followed by the player name.")

	self:Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captain[ 2 ] = self:NewCaptain( self.SecondVoted )

	end ) 

	self:CaptainsTeams()

end

function Plugin:VoteOne( Client , Vote )
	
	local ClientId = Client:GetClientId()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.MatchPlayer[ ClientId ] == true and PlayerClient ~= nil and self.SecondVote[ ClientId ] = Vote then	

		Shine:Notify( Client, "", "", "You have voted for %s !", PlayerName ) 
	
		return true 
	end 
	
	return false

end

function Plugin:VoteTwo( Client , Vote )
	
	local ClientId = Client:GetClientId()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.MatchPlayer[ Client ] == true and PlayerClient ~= nil and self.FirstVote[ ClientId ] = Vote then	

		Shine:Notify( Client, "", "", "You have voted for %s !", PlayerName ) 
	
		return true 
	end 
	
	return false

end


function Plugin:NewCaptain( Votes ) 

	local TopVoted = 0
	local Captain = nil

	local function GetCount( VoteList )
		
			for Key , Value in pairs( self.Voted ) do

				local Count = 0

				if Value == VotedId then 
				
					Count = Count + 1

				end
				
			end

			return Count

	end

	if self.Voted == nil or self.SecondVoted == nil then

		local Value , Key = self:ChooseRandom( self.MatchPlayers ) 

		Captain = Value 
		
		self.MatchPlayers[ Captain ] = nil

		return Captain

	else 

		for Key , Value in pairs( Votes ) do
			
			if Client[ Value ] ~= nil and GetCount( Value ) >= TopVoted then 
				
				Captain = Value 

			end
			
		end

		self.MatchPlayers[ Captain ] = nil

		return Captain

	end	

end

function Plugin:CaptainsTeams()	

	local Value , Key = ChooseRandom{ 1 , 2 } 
	local Team , Random = ChooseRandom{ 1 , 2 } 
	local CaptainOne = self.Captains[ 1 ] 
	local CaptainTwo = self.Captains[ 2 ]
		
	local Value , Key = ChooseRandom( self.Captain ) 

	-- tableshuffle?
	if Key == 1 then

		self.Captains[ 1 ] = CaptainOne 
		self.Captains[ 2 ] = CaptainTwo
		
		
	elseif Key == 2 then

		self.Captains[ 1 ] = CaptainTwo 
		self.Captains[ 2 ] = CaptainOne
		
	end

	if Team == 1 then

		GameRules:JoinTeam( Client[ CaptainOne ]:GetControllingPlayer() , 1 , nil , true ) 
		GameRules:JoinTeam( Client[ CaptainTwo ]:GetControllingPlayer() , 2 , nil , true ) 
		
	elseif Team == 2 then

		GameRules:JoinTeam( Client[ CaptainOne ]:GetControllingPlayer() , 2 , nil , true ) 
		GameRules:JoinTeam( Client[ CaptainTwo ]:GetControllingPlayer() , 1 , nil , true ) 
		
	end

	self:PickTeams() 
	
end

function Plugin:PickTeams()

	Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Captains are now picking teams"..GameStartTime, 5, 255, 255, 255, 1, 3, 1 ) )

	while self.MatchPlayers ~= nil do

	StringFormat( "You have %s unitl a player is randomed to your team.", self:GetTeamName( 1 ) )

		self:PickPlayer()

	end
	self:Timer.Simple( self.Config.NagInterval , function() 

		self:GetStartNag()

	end) 

	self:StartGame() 

	return true

end
	
function Plugin:PickPlayer()

	--gamestatus
	local Captain = self.CurrentCaptain 

	Shine:Notify( Captain , "", "", "It is now your turn to pick!" ) 
	Shine:Notify( Captain , "", "", "Use sh_choose in console or !choose in chat followed by a players name." ) 

	self:Timer.Simple( self.Config.VoteTimeout , function() 
		
		local Value , Key = ChooseRandom( self.MatchPlayer ) 

			self:Choose( self.CurrentCaptain , Value ) 
			self:CurrentPick()

	end )  

	return true
	
end

function Plugin:CurrentPick()

	local CaptainOne = self.Captain[ 1 ]
	local CaptainTwo = self.Captain[ 2 ]
	local PlayerOne = Client[ CaptainOne ]:GetControllingPlayer()  
	local PlayerTwo = Client[ CaptainTwo ]:GetControllingPlayer()  
	local TeamOne = Player:GetTeamSize()
	local TeamTwo = PlayerTwo:GetTeamSize()
	local MaxSize = self.Config.TeamSize
	local Captain = nil

	local function ReplaceCaptain( Captain ) 

		local Team = self.MatchPlayers[ Captain ] 	 
		local Votes = {}

			for Key , Value in pairs( self.MatchPlayers ) do

				if Value == Team then

					Votes[ Key ] = Value 

				end

			end

			CurrentCaptain =  self.NewCaptain( Votes )

			return true

	end

	if TeamOne < TeamTwo and SizeOne < MaxSize then 

		if Client[ Captain ] ~= nil then

			ReplaceCaptain[ CaptainOne ]

		else

			self.CurrentCaptain = CaptainOne 

		end

		return true

	elseif TeamOne < TeamTwo and SizeTwo < MaxSize then

		if Client[ Captain ] ~= nil then

			ReplaceCaptain[ CaptainTwo ]
			--notify of replacement

		else

			self.CurrentCaptain = CaptainTwo
		
		end
	
		return true

	end
	
	return false

end

function Plugin:Choose( Client , PlayerId )

	local ClientId = Client:GetClientId()
	local PlayerClient = GetClient( PlayerId ) 
	local Player = PlayerClient:GetControllingPlayer()  
	local Team = Player:GetTeamNumber()

	if ClientId == self.CurrentCaptain() and PlayerClient ~= nil then
		
		GameRules:JoinTeam( Player , Team , nil , true ) 

		self.MatchPlayers[ ClientId ] = nil
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn." )

		self:PickTeams() 

		return true
		
	elseif Captain ~= ClientId then 

		Shine:Notify( Client, "", "", "You are not the current Captain." )

	end 

	return false

end

function Plugin:NeedSub()

	local TeamSize = self.Config.TeamSize

	if Count( shine.GetTeamClients( 1 ) ) < TeamSize then

		--add players to teamone	
	end

	if Count( shine.GetTeamClients( 2 ) ) < TeamSize then

		--addplayers to teamtwo
	
	end 

	if Count( shine.GetTeamClients( 1 ) ) > TeamSize then

		--remove player	
	end

	if Count( shine.GetTeamClients( 2 ) ) > TeamSize then

		--remove player	
	end

end

--[[
	Record the team that players join.
]]
function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force )

	if NewTeam == 0 or NewTeam == 3 then return end
	
	local Client = Server.GetOwner( Player )

	if not Client then return end

	local ID = Client:GetUserId()

	if self.PugsStarted == true then 
	
	self.TeamMembers[ ID ] = NewTeam

	self.MatchPlayers[ ID ] = nil

end

function Plugin:JoinTeam( GameRules, Client:GetControllingPlayer, OldTEam , NewTeam , Force , ShineForce )

	local PugsStarted = self.PugsStarted
	local GameStarted = self.GameStarted 

	if PugsStarted == true or GameStarted == true then 
	
	--check if not a matchplayer
			Gamerules:JoinTeam( Player , 3 , nil ,true ) 
			return false 

	elseif PugsStarted == false and GameStarted == false then

		return true
	end

	return false

end

function Plugin:CreateCommands()

	local function ReadyUp( Client )

		if self.GameStarted then return end

		local Player = Client:GetControllingPlayer()

		if not Player then return end
		
		local Team = Player:GetTeamNumber()

		if Team ~= 1 and Team ~= 2 then return end

		if not Player:isa( "Commander" ) then

			Shine:NotifyError( Client, "Only the commander can ready up the team." )

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

				self:Notify( true, nil, "%s is now ready.", true, TeamName )

			else

				self:Notify( true, nil, "%s is now ready. Waiting on %s to start.", true, TeamName, self:GetTeamName( OtherTeam ) )
			end
			
			--Add a delay to prevent ready->unready spam.
			self.NextReady[ Team ] = Time + 5

			self:CheckStart()
		else

			Shine:NotifyError( Client, "Your team is already ready! Use !unready to unready your team." )

		end

	end

	local ReadyCommand = self:BindCommand( "sh_ready", { "rdy", "ready" }, ReadyUp, true )
	ReadyCommand:Help( "Makes your team ready to start the game." )
	
	local function Unready( Client )

		if self.GameStarted then return end

		local Player = Client:GetControllingPlayer()

		if not Player then return end
		
		local Team = Player:GetTeamNumber()

		if Team ~= 1 and Team ~= 2 then return end

		if not Player:isa( "Commander" ) then

			Shine:NotifyError( Client, "Only the commander can ready up the team." )

			return
		end

		local Time = Shared.GetTime()

		local NextReady = self.NextReady[ Team ] or 0

		if self.ReadyStates[ Team ] then

			if NextReady > Time then return end

			self.ReadyStates[ Team ] = false

			local TeamName = self:GetTeamName( Team )

			self:Notify( false, nil, "%s is no longer ready.", true, TeamName )

			--Add a delay to prevent ready->unready spam.
			self.NextReady[ Team ] = Time + 5

			self:CheckStart()
		else
			Shine:NotifyError( Client, "Your team has not readied yet! The commander has to type !ready to ready your team." )
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

	local VoteOne = self:BindCommand( "sh_vote1", { "vote1" }, VoteOne( Client , PlayerId ) )
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

	local VoteTwo = self:BindCommand( "sh_vote2", { "vote2" }, VoteTwo( Client , PlayerId ) )
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
	local Choose = self:BindCommand( "sh_choose", { "choose" } , Choose( Client , Team ) )
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

	--reset pug Startpug
	--unbockteams
	--pickteams


end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )

	self.FirstVote = nil 
	self.SecondVote = nil 

	self.TeamMembers = nil
	self.ReadyStates = nil
	self.TeamNames = nil

	Server.SetConfigSetting( "auto_team_balance", true )
	Server.SetConfigSetting( "end_round_on_team_unbalance", true )
	Server.SetConfigSetting( "force_even_teams_on_join", true )

	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
