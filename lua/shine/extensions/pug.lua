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
local GetAllPlayers = Shine.GetAllPlayers
local GetClient = Shine.GetClient 

local Plugin = Plugin
Plugin.Version = "0.5"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	TeamSize = 6, --Size of Team; if 0 the pug is based upon the # in the server  and still take there spot. 

	NagInterval = 0.3, --how often players are Nagged of the game status 

	VoteStart = 0.6 --ratio of the game size to start the captains vote; 0 waits for the game to become full.

	VoteTimeout = 0.5, --length for all vote timeouts. Captains vote, Captains Teams, Captains choose

}

Plugin.CheckConfig = true
Plugin.GameStarted = false
Plugin.PugsStarted = false

Plugin.Players = {} --player queue for who gets into the pug 

Plugin.MatchPlayers = {} --list of match players, in case of dissconnect the next player on queue subs in; parameters are there captain votes

Plugin.Votes = {} -- live count of # of votes 
--voting is a type of rank based voting. Each vote is rank of your choice. Vote 1 is your first choice. If your first vote is not one of top voted or that member is a captain then your second choice is counted. 

Plugin.Captains {}  --The first top voted to join a team after the Pug is full or Vote is finished becomes a capain. 
--If that person leaves then the next highest voted will be put on a team i
--If the person leaves after the first choice the highest voted person on the team becomes the captain
--

--add rounds ? best of 3 etc or adds to tournamentmode actually
function Plugin:Initialise()

        if self:CreateCommands() and GameStarted == false then  

		--Pick Up Game Mode enabled!

		self:Timer.Simple( self.Config.NagInterval function() 

			self:GameStatus()
			self:PlayerStatus()
	
		end )

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	
	if self.PugStarted == true then

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

Shine:Notify( Client, "", "", "Captains are deciding Teams ")
Shine:Notify( Client, "", "", "Waiting on more players to start the pug.") 
Shine:Notify( Client, "", "", "Need more votes for captains to be decided. ")
--for all nonmatchplayers key = x and notify
--The pug is full you are x in line.
--MatchPlayers
--You are in the pug
--if votedcaptains 
--pleasevote for captains by....
--For captain1 2
-
function UpdateMatchPlayers() 
	
	for Key, Value in ipairs( self.Players ) do 	
			
		if PugFull == false then
		
			self:MakeMatchPlayer( Value ) 

		elseif PugFull == true then
			--VotedCaptains 
			--else timer nag 

			return true

		end
	
	end 

	return false

end

function Plugin:MakeMatchPlayer( ClientId )

		if Client[ ClientId ] == true then
		--not sure if this works

			self.MatchPlayers[ ClientId ] = 0 	
			return true 

		end

end 

function Plugin:CheckExists( ClientId ) 

	for Key, Value in ipairs( self.Players ) do 	

		if Value == ClientId then
			
			return true
		end

	end

	if Players[#Players+1] = CliendId then
		
		return true
	
	end

	return false

end

function Plugin:NumPlayers()

	return Count( Shine.Getallclients() )

end

function Plugin:OnConnect( Client )

	local ClientId = Client:GetClientId() 

	if self:CheckExists( ClientId ) == false then 
	
		--disconnect
		--return false
	end

	if self.GameStarted == true and self:CheckSubs() == true then

		return true
	
	elseif self.PugStarted == true and self:SendToTeam( ClientId ) == true then

		return true
	
	elseif Self.PugStarted == false then 
	
		self:StartVote() 
			
		return true

	end

	return false

end
	
function Plugin:OnDisconnect( Client ) 

	local ClientId = Client:GetClientId()

	if self.GameStarted == true and self:CheckSubs() == true then 

		return true

	elseif self.PugStarted == true and self:RemoveCaptain( ClientId ) == true then

		--getteam 
		--lookfor players on team and get top player and make captain
		--find player with top votes else voteCapatins
	end
	
	return false

end



function Plugin:StartVote() 

	local PugSize = function() 
		
			return self.config.TeamSize * 2

		end

	local StartVote = self.Config.StartVote
	local Players = self:NumPlayers() 

	
	if StartVote == 0 and Players >= PugSize and self:StartPug() == true then

		return true

	elseif function() Players == StartVote * PugSize end == true and self:StartPug() == true then 

		return true
	end

	return false

end


function Plugin:StartPug()

	self.PugsStarted = true
	--creatematchplayers
	--send players to spectator
	--sendMatchPlayers to readyroom
	--tell the about till vote timeout	
	if self:Timer.Simple( self.Config.VoteTimeout , function() 

		if self:CountVotes() == true then 
			
			return true

		end

	end ) then return true end

	return false
	
end
	
function Plugin:Vote( Client , VoteOne , VoteTwo )
	
--todo display vote
	local ClientId = Client:GetClientId()

	if self.MatchPlayer[ GetClientId ] == true then 	
			--
			--matchplayer
		--check if one or two exist as a matchplayer
		--Players[ClientId][1] = VoteOne
		--Players[ClientId][2] = VoteTwo

		Shine:Notify( Client, "", "", "You have voted for xxxx xxxx!" ) 
	
		return true

	end 
	
	return false

end

function Plugin:CountVotes( ClientId )
	-- counts 1 round of votes
	for _, Value in pairs( self:MatchPlayers() )  do
				
				Votes .i = 1
			if Votes.Value.i + 1 then

			elseif  Vote.VoteId ] == true then
			Vote.VoteId = Vote.VoteId + 1
			--addcaptain to 
			--ingame
			CaptainTeams 	
	end

end

function Plugin:CaptainTeams()	

	--check if captains is on a team if  so captain joined
	--captains can now join teams you have naginterval seconds 
	self:Timer.Simple( self.Config.NagInterval , function() 
		
			self:RandomCaptains() 

		end )  
				
end
function OnTeamJoin( Client )
		
	local PugStarted = self.PugsStarted
	local ClientId = Client:GetClientId()

	if PugsStarted == true and Count( self.Captains ) == 2 and self:CaptainJoined( ClientId ) == true then

		return true

	
	elseif PugsStarted == false and self.GameStarted == false then

		return true
	end

	return false

end

function Plugin:CaptainJoined( ClientId ) 

	--make captain send other captain to otherside and make current 
	--captain notify

end

function Plugin:Choose( Client , PlayerId )

	local PlayerClient = self:GetClient( PlayerId ) 

	if self:CurrentCaptain( ClientId ) == true and self:SendToTeam( PlayerClient ) == true then

		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn." )

		Shine:Notify( self:CurrentPick(), "", "", "It is your turn to pick!" ) 

		return true
		
	elseif self:CurrentCaptain( ClientId ) == false then 

		Shine:Notify( Client, "", "", "You are not the current Captain." )

	end 

	return false

end
 

function SendToTeam( Client ) 
	
	local Client ==  Client:GetClientId()
	local MatchPlayer = self.MatchPlayer[ ClientId ] 

	local ClientId = Client:GetClientId()

	if MatchPlayer == true then

		--find team
		--or send to readyroom
		--
		return true 

	elseif MatchPlayer == false then
	
		--got spectators
		
		return true
	
	end
		
	return false

end 

function Plugin:CurrentCaptain( ClientId )

	local TeamOne = Team1.Size

	local TeamTwo = Team2.Size

	local MaxSize = self.Config.TeamSize

	if ClientId and  TeamOne < TeamTwo and SizeOne < MaxSize and ClientId == self.Captain[1] then

		return true
	 
	elseif ClientId and TeamOne < TeamTwo and SizeTwo < MaxSize and ClientId == self.Captain[2] then

		return true

	end

	return false 

end 

function Plugin:CurrentPick()

	local TeamOne = Team1.Size

	local TeamTwo = Team2.Size

	local MaxSize = self.Config.TeamSize

	if TeamOne >= 1 and TeamOne < TeamTwo and SizeOne < MaxSize then 

		return self.Captain[1] 

	elseif TeamTwo >= 1 TeamOne < TeamTwo and SizeTwo < MaxSize then

		return self.Captain[2] 

	end
	
	return false

end


function RandomCaptains() --randomchooses a team for the captains
function RandomPlayer() --chooses a random player from the readroom
function Plugin:NeedSub()
  --count team 1 count team 2 array 
  --if one is not full then move players on playersmatch to readyroom
  --if one has more player then move to readyroom 
 -- no sub avaliable
end

function Plugin:JoinTeam( Client , Player )
	--if players array< voting requirement then 
	--		send to team	
	--		return true  
	----elseif playersarray = teamrequested and voted array = 0 then 
	
	--		send them to team 
	--
	--		if playerarray = 4 then 
	--			send to team 2 
		-- 		return true 
	--	else
	--			else echo waiting for a second captain
	--end
	-
	--Only capatins can join teams at this time

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

    local Vote = self:BindCommand( "sh_vote", { "vote" }, Votes( Client , PlayerId ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
    local Choose = self:BindCommand( "sh_choose", { "choose" } , Choose( Client , Team ) )
    			
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
