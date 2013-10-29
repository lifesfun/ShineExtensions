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
	
	TeamSize = 6, --Size of Team; if 0 the pug is based upon the # in the server  and still take there spot. 

	NagInterval = 0.3, --how often players are Nagged 

	VoteFinish = 0.6 --ratio of the game size to end the captain vote when; else waits until pug is full captains with the most votes wins
	TeamTimeout = 0.1 --time before captains are randomly assigned to a team; else auto randomed
	ChooseTimeout = 0.5, --length a captain has to choose a player until randomly assigned a player; 0 creates no timeout.
	
	Rounds = 2 -- rounds played unit pug ends; else pug does not end until the next map; best of odd #s
	SpectatorSlots = 2 --number of spectator slots and will not be kicked; else 0 all players not in the pug are kicked 

}

Plugin.CheckConfig = true

Plugin.Players = {} --value is captain id, or if captain then team 1 or 2 4
Plugin.Voted = {} --id of voter + vote
Plugin.TeamSize =  self.Config.TeamSize

function Plugin:Initialise()
	--unsets stats till game start
        if self:CreateCommands() then 
	
	self:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	
	if self:GameStatus then
	--turn tournamentmode back on if enabled else
	--	add stats to true 
	--	rest game scores and etc
	--	remove captains
	--	removePlayer from queue on teams -- tracked by tournament mode
		return true

	end

	self:Timer.Simple( self.Config.NagInterval function() 

		GameStatus() 

	end )


	return false

end 

function Plugin:GameStatus( )

	if votestatus = false and CaptainsJoin == false and CaptainsPick == false then
	 
		return true

	end

	return false

end

function Plugin:VoteStatus()

	if NeedVotes then 	

		Shine:Notify( Client, "", "", "Waiting on more player to vote to choose the the captain")

		return true

	elseif NeedPlayers then  

		Shine:Notify( Client, "", "", "Need more players to start the game this is at 'minplays' so captains can shoose teams.")
		return true

	end 
 
return false

end 

function Plugin:NeedCaptJoin()
	
	if Team1 == 1 and Team2 == 0 then
		--send capt to team 2

		return true

	elseif Team2 == 1 and Team1 == 0 then 
	 	--send capt 2 team 1
		--on join random put other captain to other side.
		--nag to choose team --marine or alien
		return true

	elseif self:Time >= config.timout then 
			
		self:RandomCaptains 
		
		return true 
	end	
	--nag captains to join a team	 
	self:Timer.Simple( self.Config.NagInterval , function() 
			CaptainsTeams()
	end )


	return false

end

function Plugin:PickPlayer()

		if Team1 self.Config.TeamSize or Team2 < self.config.TeamSize then
			
			self:SetCaptain() 
		
			--Captain: It is your turn to pick
			return true
		elseif self:Time >= config.timeout then 

			--randomoneplayer:
		 	return true

		end

		self:Timer.Simple( self.Config.NagInterval , function() 

			--PickPlayer

		end )
		

	return false

end
	
function Plugin:SetCurrentCaptain()

	if Team1 == 1 and Team 2 == 1 then 

		return 1 

	elseif Team2 < Team1 then
		
		return 2

	elseif Team1 < Team2 then 

		return 1

	end
	
	return false
end

function NeedVotes()
	-- count 12 ingame first on matchplayers that have voted < VotedRation *TeamSize 
		return true
	
	return false

end

function Plugin:NeedPlayers()

	if NumPlayers < self.config.TeamSize * 2 then

		return true
	
	end

	return false

end

function Plugin:NeedSub()

  --count team 1 count team 2
  --if one is not full then move players on playersmatch to readyroom
  --if one has more player then move sub back to specatator

end

function Plugin:JoinTeam(Client , choice )
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

function Plugin:Vote( Client )
			
	local Voted = VoteStatus( ClientId )
	local Player = PlayerStatus( ClientId ) 

	if Player and not Voted then 	

		Shine:Notify( Client, "", "", "You have voted for xxxx!" ) 

	elseif Player and Voted then  

		Shine:Notify( Client, "", "", "You have revoted for xxx" ) 

	end 
	
	return false

end

function Plugin:Choose( Client )

	if  Voted[ Client:GetUserID() ] == 1 then
		
		--if SendToTeam then jointeam .... 
	
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")

		return true

		--end
	end

	return false

end

function Plugin:ClientDisconnect( Client ) 

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
    
    local Choose = self:BindCommand( "sh_choose", { "choose" } , Choose( Client , sel.Team ) )
    		
		if self:PickTwo() == "true" then end
				
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
