--[[
Shine Pug Plugin 
Pug - Queue
--]]

local Shine = Shine

local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message

local Plugin = Plugin
Plugin.Version = "0.5"

Plugin.HasConfig = true
Plugin.ConfigName = "Queue.json"

Plugin.DefaultConfig = {

	QueueEnabled = true, -- Enabled Pug Mode	
	
	LobbyTimeout = 0.5, --min before kicked if not ready or a spectator; if 0 players in server will not be kicked
	LayOverPeriod = 1, -- After match ends players non the people in game on the queue will be added followed by the next ready people from the next game. If the server is not full queue list has priority in game until this time ends. Vote starts after this for captains. --want to add queue slots that enable joining if to allow people to leave and come back. However to be fair there needs to be a function detect out of server idlers to prevent players being kicked who are in queue. Idlely it will add you to the queue with out joining and then allow reready after match. If pug is full excess players are kicked and alerted when in the next match.

	NagInterval = 0.3, --how often players are Nagged 

	SpectatorSlots = 2 --number of spectator slots and will not be kicked; else 0 all players not in the pug are kicked 
	


	ReadyQueue = 2 -- allows players to ready into the next round if the pug is full. else players on teams cannot reready until after the game is ended 

	QueueReset= false --0 Resets on map change; matches till reset.

}

Plugin.CheckConfig = true

Plugin.Queue = {} --queue 

function Plugin:Initialise()
        if self:CreateCommands() then 
	
	
	self:StartGame() end

        self.Enabled = true

        return true
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

function QueuedStatus( CliendId )

	
 --function( ClientId )if self.MatchPlayers[ ClientId ] then return true else return false end end
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
