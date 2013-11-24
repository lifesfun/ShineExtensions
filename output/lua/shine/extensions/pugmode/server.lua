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

local StringFormat = string.format
local TableEmpty = table.Empty
local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message
local GetAllClients = Shine.GetAllClients
local GetClient = Shine.GetClient 
local ChooseRandom = table.ChooseRandom
local Shuffle = table.Shuffle
local GetTeamClients = Shine.GetTeamClients
local GetClientByID = Shine.GetClientByID

local Plugin = Plugin
Plugin.Version = "1.0"

Plugin.HasConfig = true
Plugin.ConfigName = "PugMode.json"
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
Plugin.GameStatus = "GameStatus" 

function Plugin:Initialise()

	if Shine.GetGamemode() ~= "ns2" then return false end

	self.PugsStarted = false
	self.GameStarted = false

	self.Players = {} --player queue for who gets into the pug array is numeric order 
	self.FirstVote = {} 
	self.SecondVote = {}
	self.Captains = {} --If the captain leaves before the teams are chosen the next highist votes player on the team will become captain. 
	self.CurrentCaptain = nil

	self.Rounds = nil
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


	Timer.Create( self.GameStatus , self.Config.NagInterval , 1 , self:GameStatus() )  

	self.Enabled = true

	Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Pick Up Game Mode Now Enabled!", 5, 255, 255, 255, 1, 3, 1 ) )


	return true

end

function Plugin:GameStatus() 

	if Timer.Exists( self.GameStatus ) == true then
	
		Shine:RemoveText( nil, { ID = 2 } )
		Timer:Destroy( self.GameStatus )

	end

	if self.PugsStarted == false then

		local Num = self.Config.TeamSize 

		Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Waiting for the Pick up Game to begin for a "..Num.."V"..Num.."Pug", 5, 255, 255, 255, 1, 3, 1 ) )

	elseif self.GameStarted == true then

		self:CheckCommanders( Gamerules )

		local Nag = self:GetStartNag()

		if not Nag then return false end

		self:SendNetworkMessage( nil, "StartNag", { Message = Nag }, true )


	elseif self.CurrentCaptain == nil then

		Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Time to vote for captains", 5, 255, 255, 255, 1, 3, 1 ) )


	elseif self.CurrentCaptain ~= nil then

		Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Captains are now picking teams"..GameStartTime, 5, 255, 255, 255, 1, 3, 1 ) )

	end

	Timer.Create( self.GameStatus , self.Config.NagInterval , 1 , self:GameStatus() )  

	return true
		
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
	if self.GameStarted == false then return end

	local Team1 = Gamerules.team1
	local Team2 = Gamerules.team2

	local Team1Com = Team1:GetCommander()
	local Team2Com = Team2:GetCommander()

	local MarinesReady = self.ReadyStates[ 1 ]
	local AliensReady = self.ReadyStates[ 2 ]

	if MarinesReady and not Team1Com then

		self.ReadyStates[ 1 ] = false

		self:Notify( false, nil, "%s is no longer ready. A commander is required.", true, self:GetTeamName( 1 ) )

		self:CheckStart()
	end

	if AliensReady and not Team2Com then

		self.ReadyStates[ 2 ] = false

		self:Notify( false, nil, "%s is no longer ready. A commander is required.", true, self:GetTeamName( 2 ) )

		self:CheckStart()
	end

end

function Plugin:StartGame( Gamerules )
	
	-- does stats need to be reenabled ? 
	Timer.Destroy( self.GameStatus ) 

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
	self.CurrentCaptain = nil

end

function Plugin:GetTeamName( Team )

	if self.TeamNames[ Team ] then

		return self.TeamNames[ Team ]

	end

	return Shine:GetTeamName( Team, true )

end

function Plugin:CheckStart()

	if self.GameStarted == false then return end

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


	--One or both teams are not ready, halt the countdown.
	elseif Timer.Exists( self.CountdownTimer ) then

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

function Plugin:EndGame( GameRules , WinningTeam ) 

	local RoundsLeft = self.RoundsLeft

	if RoundsLeft ~= 0 then
		
		self.RoundsLeft = RoundsLeft - 1

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
		
		 self.TeamMembers = nil
		 self.PugsStarted = false
		 self.GameStarted = false
		 self:StartPug()

	
	end
	--changemap? save player queue 
	
end
--[[
	Rejoin a reconnected client to their old team.
]]
function Plugin:ClientConnect( Client )
	
	if Client:GetIsVirtual() == true then return end

	local ID = Client:GetUserID() 
	local PugsStarted = self.PugsStarted
	local GameStarted = self.GameStarted

	local PlayerExist = function( ID ) 

		for Key, Value in ipairs( self.Players ) do 	

			if Value == ID then
				
				return true
			end

		end

		if Players[ #Players + 1 ] == ID then
			
			return true
		
		end

		return false

	end

	if self.TeamMembers[ ID ] then

		Gamerules:JoinTeam( Client:GetControllingPlayer(), self.TeamMembers[ ID ], nil, true )     

	end

	if GameStarted == true and PugsStarted == true then 

		self:NeedSubs() 

		if self.Players[ ID ] then 

			GameRules:JoinTeam( Client:GetControllingPlayer() , 0 , nil , true ) 

		end

		return true

	elseif PugsStarted == true and GameStarted == false then

		if self.Players[ ID ] then 
		
			GameRules:JoinTeam( Client:GetControllingPlayer() , 3 , nil , true ) 

		end

		return true

	elseif PugsStarted == false and self:StartPug() == false then 
		
		local Num = self.Config.TeamSize * 2 

		Num = Num - Count( GetAllClients()) 
		self:Notify( false, nil , "%s more players required to start the Pueegh", true , Num )

		return true

	end

	return false

end

function Plugin:ClientDisconnect( Client ) 

	local ID = Client:GetUserID() 

	if self.GameStarted == true and self.PugsStarted == true then 
	
		self:NeedSub() 

		return true

	elseif self.PugsStarted == true then

		if self.Captains[ 1 ] == ID or self.Captains[ 2 ] == ID then

			self:ReplaceCaptain( ID )
			
		end

		return true

	end
	
	return false

end

function Plugin:ReplaceCaptain( ID ) 

	local Team = self.TeamMembers[ ID ] 
	local Votes = {}
	local Captain = nil

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

	GameRules:JoinTeam( Client , Team , nil , true ) 

	self.Captains[ Team ] = Captain
	self:PickPlayer() 

	Shine:Notify( false , nil , "One of the captains has left the game. %s is the new captain." , true , PlayerName )

	return true

end

function Plugin:StartPug()

	local MatchSize = self.Config.TeamSize * 2
	local Players = Count( GetallClients() )

	if Players >= MatchSize then 
	
		self.RoundsLeft = self.Config.Rounds

		self:CreateTeamMembers() 

		self:StartVote() 

		return true
	
	end

	return false

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

	for i , ID in ipairs( self.Players ) do 	
			
		if Count( self.TeamMembers ) >= MatchSize then 

			FixArray( self.Players )  

			return true

		end

		self:MakeMatchPlayer( ID )
		self.Players[ i ] = nil

	end

	return false
		
end

function Plugin:StartVote() 

	local Players = Shine.GetAllPlayers 
	
	self.PugsStarted = true  

	self:GameStatus()

	for Value , Key in pairs( Players ) do

		local Player = Value:GetControllingPlayer()

		GameRules:JoinTeam( Value , 3 , nil , true ) 

	end

	for Value , Key in pairs( self.TeamMembers ) do

		local Client = GetClientByID( Key ) 
		local Player = Player:GetControllingPlayer() 

		GameRules:JoinTeam( Value , 0 , nil , true ) 

	end

  
	Shine:Notify( false , nil , "Players have %s to vote for the first captain.", true ,  self.Config.VoteTimeout )
	Shine:Notify( false, nil ,  "Use sh_vote1 in console or !vote1 in chat followed by the player name.", true  )

	Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captain[ 1 ] = self:NewCaptain( self.FirstVote ) 

	end ) 

	Shine:Notify( false , nil , "Players have %s to vote for the first captain.", true ,  self.Config.VoteTimeout )
	Shine:Notify( false, nil ,  "Use sh_vote2 in console or !vote2 in chat followed by the player name.", true  )

	Timer.Simple( self.Config.VoteTimeout , function() 

		self.Captains[ 2 ] = self:NewCaptain( self.SecondVote )

	end ) 

	self:CaptainsTeams()

	return true

end

function Plugin:VoteOne( Client , Vote )

	if self.GameStarted == false then return end
	if not Client then return end	

	local ID = Client:GetUserID()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.TeamMembers[ ID ] == true and PlayerClient ~= nil and self.SecondVote[ ID ] == Vote then	

		Shine:Notify( Client, "", "", "You have voted for %s !", PlayerName ) 
	
		return true 
	end 
	
	return false

end

function Plugin:VoteTwo( Client , Vote )
	
	if self.GameStarted == false then return end
	if not Client then return end	

	local ID = Client:GetUserID()
	local PlayerClient = GetClient( Vote ) 
	local PlayerName = GetClientByName( Vote ) 

	if self.TeamMembers[ ID ] == true and PlayerClient ~= nil and self.FirstVote[ ID ] == Vote then	

		Shine:Notify( Client, "", "", "You have voted for %s !", PlayerName ) 
	
		return true 
	end 
	
	return false

end


function Plugin:NewCaptain( VoteList ) 

	local TopVoted = 0
	local Captain = nil
	local TeamMembers = {} 

	local function GetCount( VoteID )
		
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
		local Count = GetCount( Value )

		if Client ~= nil and Key ~= self.Captains[ 1 ] or self.Captains[ 2 ] and Count >= TopVoted then 

			TopVoted = Count
			Captain = Key 

		end
	end

	return Captain

end

function Plugin:CaptainsTeams()	

	local Player = {}
	local CaptainOne = GetClientByID( self.Captains[ 1 ] )
	local CaptainTwo = GetClientByID( self.Captains[ 2 ] )

	Player[ 1 ] = CaptainOne:GetControllingPlayer() 
	Player[ 2 ] = CaptainTwo:GetControllingPlayer() 

	Shuffle( self.Captains )
	Shuffle( Player )

	GameRules:JoinTeam( Player[ 1 ] , 1 , nil , true ) 
	GameRules:JoinTeam( Player[ 2 ] , 2 , nil , true ) 

	self:PickTeams() 
	
end

function Plugin:PickTeams()

	self:GameStatus()

	Shine:SendText( nil, Shine.BuildScreenMessage( 2, 0.5, 0.7, "Captains are now picking teams"..GameStartTime, 5, 255, 255, 255, 1, 3, 1 ) )

	
	while  Count( shine.GetTeamClients( 0 ) ) ~= 0 do

		Shine:Notify( Captain , "", "", "You have %s unitl a player is randomed to your team.", self.Config.VoteTimeout )

		self:PickPlayer()

	end

	self.GameStarted = true
	self:GameStatus()

	return true

end
	
function Plugin:PickPlayer()

	local Captain = GetUserByID( self.CurrentCaptain ) 

	Shine:Notify( Captain , "", "", "It is now your turn to pick!" ) 
	Shine:Notify( Captain , "", "", "Use sh_choose in console or !choose in chat followed by a players name." ) 

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

	if self.GameStarted == false then return end
	if not Client then return end	

	local ID = Client:GetUserID()
	local PlayerClient = GetClient( PlayerID ) 
	local Player = PlayerClient:GetControllingPlayer()  
	local Team = Player:GetTeamNumber()

	if ID == self.CurrentCaptain and PlayerClient ~= nil then
		
		GameRules:JoinTeam( Player , Team , nil , true ) 

		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn." )

		self:PickTeams() 

		return true
		
	elseif Captain ~= ID then 

		Shine:Notify( Client, "", "", "You are not the current Captain." )

	end 

	return false

end

function Plugin:RemovePlayer( Team )

	
	for Key , Value in ipairs( self.Players ) do

		local Client = GetClientByID( Value )
		local Player = Client:GetControllingPlayer()
		local PlayerName = Player:GetName()

		if Player:GetTeamNumber() == Team then

			GameRules:JoinTeam( Player , 3 , nil , true ) 
			Shine:Notify( false , nil , "A team member has joined the game. The sub %s is being moved to spectator.", true ,  PlayerName )

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

			GameRules:JoinTeam( Player , Team , nil , true ) 

			Shine:Notify( false , nil , "A team member has left the game. The sub %s is the being substituted.", true , PlayerName )

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

--[[
	Record the team that players join.
]]
function Plugin:PostJoinTeam( Gamerules, Player, OldTeam, NewTeam, Force )

	if PugsStarted == false and GameStarted == false then return end 
	if PugsStarted == true and GameStarted == false then return false end 
	
	if OldTeam == 0 or 3 and NewTeam == 0 or 3 then return end
	
	local Client = Server.GetOwner( Player )

	if not Client then return end

	local ID = Client:GetUserID()

	if self.PugsStarted == true then 
	
		self.TeamMembers[ ID ] = NewTeam

	end

	return false
end

function Plugin:JoinTeam( GameRules , Player , NewTeam , Force ) 

	if self.PugsStarted == false then return end

	if PugsStarted == true and GameStarted == false then return false end 

	if NewTeam == 0 or NewTeam == 3 then return end

	return false
	

end

function Plugin:CreateCommands()

	local function ReadyUp( Client )

		if self.GameStarted == false then return end

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

		if self.GameStarted == false then return end

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

	local VoteOneCommand = self:BindCommand( "sh_vote1" , { "vote1" } , pugmode:VoteOne , true )
    	VoteOneCommand:AddParam{ Type = "string" , Default = "" }    


	local VoteTwoCommand = self:BindCommand( "sh_vote2" , { "vote2" } , self.VoteTwo , true )
    	VoteTwoCommand:AddParam{ Type = "string" ,  Default = "" }    
    
	local ChooseCommand = self:BindCommand( "sh_choose" , { "choose" } , self.Choose  , true )
    	ChooseCommand:AddParam{ Type = "string" ,   Default = "" }    

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

