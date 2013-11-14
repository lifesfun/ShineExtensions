--[[
Shine Pug Plugin 
Pug - Pick Up Games
	This creates array of players in order to manage the formation of teams.
	Progression:
		Amount needed to be enabled and start nagging
		Player either ready or become a spectator; else are kicked after the timeout amount
		Captatins are decided when the percentage of matchsize votes or when the pug fills up

		Once captain is decided spectators and non-readied players are sent into spectator.
			All other players are put in the ready room.
			All players except the commander are blocked from switching teams and joining
			Commanders will be randomed if they surpass the teamtimeout
			Round is reset
		Captains then have to decide there players and are limited by the choosetimeout
		Players are picked from the ready room and placed on the same side as the commander
--]]

local Shine = Shine

local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message
local GetAllClients = Shine.GetAllClients
local GetClient = Shine.GetClient 

local Plugin = Plugin
Plugin.Version = "0.98"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"
Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	TeamSize = 6, --Size of Team
	
	NagInterval = 0.3, --how often players are Nagged of the game status 

	VoteTimeout = 0.5, --length for all vote timeouts. Captains vote, Captains Teams, Captains choose

}

Plugin.CheckConfig = true

function Plugin:Initialise()

	Plugin.Players = {} --player queue for who gets into the pug array is numeric order 
	Plugin.MatchPlayers = {} --list of match players, in case of disconnect the next player on queue subs in; parameters are there captain votes
	Plugin.Captain {}  --The first captain to join a team after the VoteTimeout will get second pick. 
	--If the captain leaves before the teams are chosen the next highist votes player on the team will become captain. 
	Plugin.CurrentCaptain = nil

	Plugin.GameStarted = false
	Plugin.PugsStarted = false

	Plugin.FirstVote = {} 
	Plugin.SecondVote = {}
	Plugin.CurrentCaptain = nil



        if self:CreateCommands() and GameStarted == false then  

		--Pick Up Game Mode enabled!
		
		self:StartPug()
		self:GameStatus()

		self.Enabled = true

		return true

	end

	return false

end

function Plugin:StartGame()
	
	if self.GameStarted == false then

	--	if stats enabeld add stats to true 
	--	start tournament mode with tracking players for teams
	--	send MatchPlayer to back of the queue
	--
	-- 	clear arrays
	--		voted
	--		captains
	--		MatchPlayers
	--
		GameRules:ResetGame()
		self.GameStarted = true
		self.PugsStarted = false

		return true

	end

	return false

end 

function Plugin:GameStatus()

--funciton messages for game and player statuses
--Shine:Notify( Client, "", "", "Captains are deciding Teams ")
--Shine:Notify( Client, "", "", "Waiting on more players to start the pug.") 
--Shine:Notify( Client, "", "", "Need more votes for captains to be decided. ")
--for all nonmatchplayers key = x and notify
--The pug is full you are x in line.
--MatchPlayers
--You are in the pug
--if votedcaptains 
--pleasevote for captains by....
--For captain1 2
end

function Plugin:OnConnect( Client )

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

	if PlayerExist == false then 
		
		--disconnect
		--return false
	end

	if self.GameStarted == true and self:CheckSubs() == true then

		return true
	
	elseif self.PugStarted == true and self:SendToTeam( ClientId ) == true then

		return true
	
	elseif self.PugStarted == false and self:StartPug() == true then
			
		return true

	end

	return false

end

function Plugin:OnDisconnect( Client ) 

	if self.GameStarted == true and self:CheckSubs( Client ) == true then 

		return true

	elseif self.PugStarted == true and self:ManageCaptains( Client ) == true then

		return true

	end
	
	return false

end

function Plugin:StartPug()

	local MatchSize = self.Config.TeamSize * 2
	local Players = Count( GetallClients() )


	if  Players >= MatchSize and self:CreateMatchPlayers() == true and self:StartVote() == true and  then

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

	for i, ClientId in ipairs( self.Players ) do 	
			
		if Count( self.MatchPlayers ) >= MatchSize then 

			FixArray( self.MatchPlayers )  

			return true

		end

		self:MakeMatchPlayer( ClientId )
		self.Players[ i ] = nil

	end

	return false
		
end

function Plugin:StartVote() 

	local CaptainOne
	local CaptainTwo

	self.PugsStarted = true  

	--gamestatus
	--send players to spectator
	--sendMatchPlayers to readyroom
	--vote for voth captains ....

	self:Timer.Simple( self.Config.VoteTimeout , function() 

		CaptainOne = self:NewCaptain( self.FirstVoted ) 

	end ) 

	self:Timer.Simple( self.Config.VoteTimeout , function() 

		CaptainTwo = self:NewCaptain( self.SecondVoted )

	end ) 

	self:CaptainsTeams( CaptainOne , CaptainTwo )

end

function Plugin:VoteOne( Client , Vote )
	
	local ClientId = Client:GetClientId()

	if self.MatchPlayer[ GetClientId ] == true and self.SecondVote[ ClientId ] = Vote then	

		Shine:Notify( Client, "", "", "You have voted for xxxx xxxx!" ) 
	
		return true 
	end 
	
	return false

end

function Plugin:VoteTwo( Client , Vote )
	
	local ClientId = Client:GetClientId()

	if self.MatchPlayer[ GetClientId ] == true and self.FirstVote[ ClientId ] = Vote then	

		Shine:Notify( Client, "", "", "You have voted for xxxx xxxx!" ) 
	
		return true 
	end 
	
	return false

end


function Plugin:NewCaptain( Votes ) 

	local TopVoted = 0
	local Captain = nil

	local function GetCount( Votes )
		
			for Key , Value in pairs( self.Voted ) do

				local Count = 0

				if Value == VotedId then 
				
					Count = Count + 1

				end
				
			end

			return Count

	end

	if self.Voted == nil or self.SecondVoted == nil then

		Captian = self:RandomCaptain() 

		return Captain

	else 

		for Key , Value in pairs( Votes ) do
			
			if Client[ Value ] ~= nil and GetCount( Value ) >= TopVoted then 
				
				Captain = Value 

			end
			
		end

		return Captain

	end	

end

function Plugin:RandomCaptain()

end

function Plugin:CaptainsTeams( CaptainOne , CaptainTwo )	
		
		local TeamOne
		local TeamTwo

		local function() 

	--function random capatin 1 and two
		end
		local function() 
	--and send to random team	
		end
		
		self.Captains[ 1 ] = CaptainOne 
		self.Captains[ 2 ] = CaptainTwo

		self.MatchPlayer[ Captain1 ] = TeamOne
		self.MatchPlayer[ Captain1 ] = TeamTwo
		
end

function Plugin:RandomPlayer()

end

function Plugin:PickTeams()

	local function StillPlayers()

		for Key , Value in pairs( self.MatchPlayers ) do

			if Client [ Key ] ~= nil and Value == 0 then
				
				return true

			end

		end

		return false
	end

	while StillPlayers() == true do

		self:PickPlayer()

	end
	
	for Key , Value in pairs( self.MatchPlayers ) do
		
		if Value == 0 then
			
		--randomPlayer
	
		end
	
	end
	
	self:StartGame() 

end
	
function Plugin:PickPlayer()

	--gamestatus
	local Captain = self.CurrentCaptain 

	Shine:Notify( Captain , "", "", "It is now your turn to pick!" ) 

	self:Timer.Simple( self.Config.VoteTimeOut , function() 
		
		--randomplayertoteam
		self:CurrentPick()

	end )  

	return true
	
end

function Plugin:CurrentPick()

	local CaptainOne = self.Captain[1]
	local CaptainTwo = self.Captain[2]
	local TeamOne = TeamOne[ team of the captain 1].Size
	local TeamTwo = TeamTwo[ same as above ].Size
	local MaxSize = self.Config.TeamSize

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

		else


			self.CurrentCaptain = CaptainTwo
		
		end
	
		return true

	end
	
	return false

end

function Plugin:Choose( Client , PlayerId )

	local ClientId = Client:GetClientId()
	local PlayerClient = self:GetClient( PlayerId ) 

	local function CanPick( PlayerId )

		local Client = GetClient( PlayerId ) 

		if Client[ Client ] ~= nil and self.MatchPlayer[ Client:GetClientId() ] == true then 
		--check if not on team

			return true 
		
		end
			
		return false

	end 

	if ClientId == self:CurrentCaptain() and self:CanPick( PlayerId ) == true then
		
	--GameRules:JoinTeam( Client:GetControllingPlayer, get captains team ) 

		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn." )

		self:PickTeams() 

		return true
		
	elseif Captain ~= ClientId then 

		Shine:Notify( Client, "", "", "You are not the current Captain." )

	end 

	return false

end

function Plugin:NeedSub()

  --count team 1 count team 2 array 
  --if one is not full then move players on playersmatch to readyroom
  --if one has more player then move to readyroom 
 -- no sub avaliable
 
end

function Plugin:JoinTeam( GameRules, Client:GetControllingPlayer, OldTEam , NewTeam , Force , ShineForce )

	-- check captain or send to team block f4 etc	
	
	local PugsStarted = self.PugsStarted
	local ClientId = Client:GetClientId()

	if self.Captains[ ClientId ] ~= nil and PugsStarted == true and self:ManageCaptains() == true then 

		return true

	elseif PugsStarted == false and self.GameStarted == false then

		return true
	end

	return false

end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce )

	local Player = player:GetPlayer()
	local playerTeam = Client:GetPlayer():GetTeam():GetTeamNumber()

	if playerTeam ~= 0 then Shine:Notify( Client, "", "", "You can only choose players from the Ready Room") return end
            Gamerules:JoinTeam( Player, playerTeam, nil, true )

	return false

end

function Plugin:CreateCommands()

    local VoteOne = self:BindCommand( "sh_vote", { "vote" }, VoteOne( Client , PlayerId ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

    local VoteTwo = self:BindCommand( "sh_vote", { "vote" }, VoteTwo( Client , PlayerId ) )

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
	
	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
