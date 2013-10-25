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
	On disconnect:
		If teams are not fully picked and a captain leaves, 
			server will use the current votes to decide the second commader
		If a teams are picked and a player leaves, a the next queued player is placed on the team. 
			If the player rejoins then the queue player will be moved back to spectator.
	Player Queue:
		Players on the queue remain there until Teams are being picked. This means you can leave the server and come back and still be in the queue. If a player disconnects and is on a team. The highest member on the queue, that is in game is subbed in. The subbed in player will be forced back to spectator if the original player reconnects. 
		--todo make sure scores are kept, and res is synced and tranfered b/t player and sub
		--todo make a queue that will kick player lower on the list if player starts to connect
		--Queue system. Confirms queued members else are placed to the back of the line
	--report reserved slot if player leaves
	--For start 
	--Startgame
	--	checkstart - min AtCapacity Notify rounds  
	--	resetround
	--	enablestats
	--	else nag
	--Endgame 
	--	Rounds- add score with captains name ,subtract round
	--	Delay 5
	--	Switch captain teams
	--	move players
	--
	--
	-- 	else 
	-- 		nonreadied
	-- 			kicking in type ready or spectate
	--		queued
	--			pug is now full you are 3 on the list
	--			etc info
	-- 		spec
	-- 			teams voting
	-- 			captains picking
	-- 		voting
	-- 			players 
	-- 				vote for captain
	-- 				waiting for end vote signal
	-- 			captian 
	-- 				you are a captin wait tillend vote signal
	--
	--		captain choose
	--			players 
	--				wait for captaisn to choose teams
	--			captain
	--				waiting for other captain
	--				your turn you have x seconds
	--	
--]]

local Shine = Shine

local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message

local Plugin = Plugin
Plugin.Version = "0.5"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	MinPlayersToStart = 8, --players to start the pug vote	
	
	LobbyTimeout = 0.5, --min before kicked if not ready or a spectator; if 0 players in server will not be kicked
	LayOverPeriod = 1, -- After match ends players non the people in game on the queue will be added followed by the next ready people from the next game. If the server is not full queue list has priority in game until this time ends. Vote starts after this for captains. --want to add queue slots that enable joining if to allow people to leave and come back. However to be fair there needs to be a function detect out of server idlers to prevent players being kicked who are in queue. Idlely it will add you to the queue with out joining and then allow reready after match. If pug is full excess players are kicked and alerted when in the next match.

	TeamSize = 6, --Size of Team; if 0 the pug is based upon the # in the server  and still take there spot. 

	NagInterval = 0.3, --how often players are Nagged 

	SpectatorSlots = 2 --number of spectator slots and will not be kicked; else 0 all players not in the pug are kicked 
	


	ReadyQueue = 2 -- allows players to ready into the next round if the pug is full. else players on teams cannot reready until after the game is ended 

	VoteFinish = 0.6 --ratio of the game size to end the captain vote when; else waits until pug is full captains with the most votes wins
	TeamTimeout = 0.1 --time before captains are randomly assigned to a team; else auto randomed
	ChooseTimeout = 0.5, --length a captain has to choose a player until randomly assigned a player; 0 creates no timeout.
	
	Rounds = 2 -- rounds played unit pug ends; else pug does not end until the next map; best of odd #s

	QueueReset= false --0 Resets on map change; matches till reset.

}

Plugin.CheckConfig = true

Plugin.Queue = {} --queue 
Plugin.Players = {} --value is captain id, or if captain then team 1 or 2 4
Plugin.Voted = {} --id of voter + vote
Plugin.Spectator = {}--id 
Plugin.Rounds = self.Config.Rounds 
Plugin.GameSize = 2 * self.Config.TeamSize

function Plugin:Initialise()
	--unsets stats till game start
   	--overrides rounds in mapvote plugin  
        if self:CreateCommands() then 
	
	
	self:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	
	if self:CheckStart() then

	--	rest game scores and etc
	--	add stats to true 
	--
		return true

	end

	return false

end 

function Plugin:CheckStart()


	return false

end

function EndGame()

	if self.Rounds == 1 then

		--Remove all players from players array
		self.Rounds = self.Config.Rounds	

		return true
		
	elseif self.Rounds > 0 then 
			
		self.Rounds = selfs.Rounds - 1 

		return true

	end	

		return false	

end
	--if queued and decided queue status.. queued

function Plugin:MatchStatus()
	--need minimumplayer
		--Start vote nag
		--top of the queue can vote and become players
		--if higher joins then player can be be taken out of the game. During layover period until end.
	--Voting 
		--create match players
		--wait until captains ratio or match size
		--create the 2 captains send people to readyroom
		--start capt choose nag
	--Choosing >= Two captains
		--assign current captain 
		--choosing algorythm
		--Started if 6 on a player team 
	--RoundsLeft
	--needed queue players
	
		
end

function 
if 1 <=  NumPlayers < TeamSize and Num == 2, 
1 
function Plugin:Turns
--if team 1 = 1 
--if  team 1 = 2, 4, 6, 8, 10, 12
--
function Plugin:CaptainsPick( cap1 , cap2 )
	Move	
	
function Plugin:OnePick()
	if N1 == TeamSize -1 or N2 == TeamSize - 1 then 
		return true	
	elseif N1 == 1 and N1 == 1 then
		return true
	elseif N1 == 
	
	return false 

function Plugin:DeterminePick( N1 , N2 )
	if N1 < N2 then
		P = T1
		return true
	elseif N1 > N2 then	
		P = T2
		return true 
	elseif N1 == N2 then
		P = T1
		return true 
	end

	return false

end

function Plugin:Queue( )

	return false

end

function Plugin:TrackClients()
	--look through clients 
	--	after 5 min warn
	--	if Client not on queue or players or spectators then kick 

end

function Plugin:TrackPlayers( Client )		
	--	if on 1 || 2 then 
	--		loop through team 
	--			move lowest queued player to ready 
	--		move player to their team
	--			return true
	--		end
	--
	-- 	 elseif if queued 
	-- 	 	if playersonteam < teamsize then
	--			grab top of the ingame queue 
	--			place on team
	--			return true 
	--	 	else place to 0
	--	 		return true 
	--	 elseif spectator
	--	  	place to spectate
	--		return true 
	--	else 
	--		send to readyroom
	--		nag unreadied player
	--	end
	--end
	--
	return false

end

function Plugin:JoinTeam(Client , choice )
	--if players array< voting requirement then 
	--		send to team	
	--		return true  
	--
	--elseif playersarray = teamrequested and voted array = 0 then 
	
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

function Plugin:MinPlayers()

	if Shared.GetEntitiesWithClassname( "Player" ):GetSize() >= self.Config.MinPlayersToStart then

		return true 
	
	end	
	
	return false

end

function QueuedStatus( CliendId )

	
 --function( ClientId )if self.MatchPlayers[ ClientId ] then return true else return false end end
	return false

end 

function Plugin:PlayerStatus( ClientId )
	--if minimumplayers
	--check if MatchPlayer[ Id] = 4 return true
	
	return false

end

function Plugin:CaptainStatus( ClientId )
	--check if MatchPlayer[ Id] = 4 return true
	
	return false

end

function Plugin:CurrentCaptain( ClientId )
	--check if Voted[ Id] = 1 return true
	
	return false

end
function Plugin:VotedStatus( ClientId )
		--check voted [clid] == false
		--return true
	return false

end

function Plugin:SpectatorStatus()
	-- if spectator (clientid) then
	-- return true

	return false

end

function Plugin:Vote( Client )
			
	local Voted = VoteStatus( ClientId )
	local Player = PlayerStatus( ClientId ) 

	if Player and not Voted then 	

		Shine:Notify( Client, "", "", "You have voted for xxxx!" ) 

	elseif Player and Voted then  

		Shine:Notify( Client, "", "", "You have revoted for xxx" ) 

	elseif not Player then  

		Shine:Notify( Client, "", "", "You have to be in the pug to vote, you are x in cue")

	end 
	
	return false

end

function Plugin:Choose( Client )

	if  Voted[ Client:GetUserID() ] == 1 then
		
		--if SendToTeam then 
	
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")

		return true

		--end
	end

	return false

end

function Plugin:Ready( Client )

	local ClientId = Client:GetClientId() 
	local Full = self:AtCapacity()	
	
	if not Full and not Readied then

		Shine:Notify( Client, "", "", "You have joined the Pug! Wait for Captain Vote.")

		return true 

	elseif Readied then
 		
		Shine:Notify( Client, "", "", "You have already joined the pug. Type !unready to leave.") 
		return true 

	elseif Full then 
	
		Shine:Notify( Client, "", "", "The pug is full. You are now in the queue") 
		return true
	end

	return false
end

function Plugin:ClientDisconnect( Client ) 

	remove[	self.Readied[ Client:GetUserId() ] ] and FixArray( self.Readied )  

	remove[ self.Captain[ Client:GetUserId() ] ] and FixArray( self.Captain )
	
	remove[ self.Voted[ Client:GetUserId() ] ] and FixArray( Voted.Captain )

	remove[ self.Spectator[ Client:GetUserId() ] ] and FixArray( Spectator.Captain )

	return false

end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce )

	local Player = player:GetPlayer()
	local playerTeam = Client:GetPlayer():GetTeam():GetTeamNumber()

	if playerTeam ~= 0 then Shine:Notify( Client, "", "", "You can only choose players from the Ready Room") return end
            Gamerules:JoinTeam( Player, playerTeam, nil, true )

	return false
end

function Nag( Client ) 

	local ClientId = Client:GetUserId()
	local Ready = ReadyStatus( ClientId ) 
	local Voted = VoteStatus( ClientId )
	local Captain = CaptainStatus( Client )
	local Full = AtCapacity()

	if Ready and not Captain then 
		
		NagReadied( Client )	

	elseif Ready and Captain then

		NagCaptains( Client ) 

	elseif Full then

		Shine:Notify( Client, "", "", "Pug Mode is enabled, however is full wait for the rounds to finish and then type !rdy to join the next Pueggg!")

	else
	
		Shine:Notify( Client, "", "", "Pug Mode is enabled and not Full. Type !rdy to join the Pueggg!")

	end
 
	self:Timer.Simple( self.Config.NagInterval , function() 
		self:StartGame()

	end )

	return false

end


function Plugin:NagReadied( Client )
		
	local Voted = VoteStatus( ClientId )

	if not Minplayers then 	

		Shine:Notify( Client, "", "", "Waiting on more players to join the pug to start the captain vote.")

	elseif not Voted and Player then  

		Shine:Notify( Client, "", "", " Captain Vote has started. Type !vote followed by part of their player name to vote.")

	elseif Voted and MinPlayers then  

		Shine:Notify( Client, "", "", "Waiting on Captain vote to finish.")

	end 
	
	return false

end 
function Plugin:CreateCommands()

    local Ready = self:BindCommand( "sh_spectator" , { "spec" , "spectator" } , CheckVotes( Client ) )

    	Ready:Help ( "Join the Pug" )

    local Ready = self:BindCommand( "sh_ready" , { "rdy" , "ready" } , CheckVotes( Client ) )

    	Ready:Help ( "Join the Pug" )
    
    local Ready = self:BindCommand( "sh_unready" , { "unrdy" , "unready" } , CheckVotes( Client ) )

    	Ready:Help ( "Leaves the pug" )

    local Vote = self:BindCommand( "sh_vote", { "vote" }, CheckVotes( Client , Player  ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
    local Choose = self:BindCommand( "sh_choose", { "choose" } , CheckVotes( Client , Player ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

    local Ready = self:BindCommand( "sh_assign" , { "assign" } , CheckVotes( Client ) )

    	Ready:Help ( "Assigns Player to a team" )
    
	--marine spectator captain ready remove
    local Ready = self:BindCommand( "sh_redo", { "redo" } , CheckVotes( Client ) )

    	Ready:Help ( "Starts a new vote for ready players or captains" )
	--vote choose 

    local Ready = self:BindCommand( "sh_round" , { "round" } , CheckVotes( Client ) )

    	Ready:Help ( "Adds the number of rounds or 0 ends the current round" )
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
