--[[
Shine Pug Plugin 
Pug - Pick Up Games
	Mod Types: 


--ns2stats history
--player readied for gametype:lobby:localserverlobby:browser
--
--Party:6v6:2rounds:timelimit:team1:team2:readyroom:admin:etc
--			cool
--			bro
--			sup
--6v6:vanilla:tournament(trackplayers):basecommands:ns2stats
--gameserver:playerCap:gamebranchtype:monitor:team1:team2:2
--match:server:teams:typegame::
--rounds=@group,team
--team=1:captchoosen + 5 players
--
--]]

local Shine = Shine

local Timer = Shine.Timer
local FixArray = table.FixArray
local Count = table.Count
local Notify = Shared.Message

local Plugin = Plugin
Plugin.Version = "0.1"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	MinPlayersToStart = 1, --players to start the pug mode	
	TeamSize = 6, --Size of Team; if 0 the pug is based upon the # in the server 

	NagInterval = 0.3, --how often players are Nagged 

	SpectatorSlots = 2 --number of spectator slots if 0 all players not in the pug are kicked 
	

	LobbyTimeout = 1, --min before kicked if not ready or a spectator; if 0 players will not be kicked

	Ready Queue = 2 -- allows players to ready into the next round once the pug is full. Players on teams cannot reready until after the game is ended 

	VoteFinish = 0.6 --ratio of the game size to end the captain vote when; if 0 waits untill pug is full 

	ChooseTimeout = 0.5, --length a captain has to choose a player until randomly assigned a player
	
	Rounds = 2 -- rounds played unit pug ends and pug does not end until the next map
}

Plugin.CheckConfig = true

Plugin.Queue = {}
Plugin.Readied = {} --number value that states which team they are on 0 readied, 1 marines, 2 aliens, 3 spectator
Plugin.Voted = {} --id vote
Plugin.Captain = {} --captain; 1 = current captain 
Plugin.Spectator = {}--id 
Plugin.Rounds = self.Config.Rounds 


--When Captain Vote ends round resets players readied are placed in the readyroom; Spectators, non Readied players, Players in the queue are placed into the spectators.

function Plugin:Initialise()
	--block gamestart
   	--check rounds from mapvote and override  
        if self:CreateCommands() then Plugin:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	
	--if pregame and gamestatus then
	--	rest game scores and etc
	--	subtract round 
	--	add stats to true 
	--	return true
	--end
	--nag 
	--
	--return false
	
		
end 

function EndGame()

	if PluginRounds == 1 then
		--Remove all from Readied except Spectators 

		return true
		
	elseif Plugin.Rounds > 0 then 
			
		Plugin.Rounds = Plugins.Rounds - 1 

		return true

	end	

		return false	

end

function Plugin:GameStatus()

--[[round:teams:mode	
--	need minplayers
--	need capacity
	voting
	captains 
	warmup
	else
	true
		--]]
end

function Plugin:AtCapacity()

	local NumPlayers = Count( Plugin.Readied )

	if NumPlayers < self.Config.GameSize then 
	
		return false 
	
	else 
	
		return true 

	end 

end

function Readied( CliendId )

 --function( ClientId )if Plugin.MatchPlayers[ ClientId ] then return true else return false end end
	return false

end 

function Plugin:CurrentCaptain( ClientId )
	
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
 
	Plugin:Timer.Simple( self.Config.NagInterval , function() 
		Plugin:StartGame()

	end )

	return false

end

function Plugin:NagCaptains()

	return false

end

function Plugin:NagReadied( Client )
		
	local Voted = VoteStatus( ClientId )

	if not Minplayers then 	

		Shine:Notify( Client, "", "", "Waiting on more players to join the pug to start the captain vote.")

	elseif not Voted and MinPlayers then  

		Shine:Notify( Client, "", "", " Captain Vote has started. Type !vote followed by part of their player name to vote.")

	elseif Voted and MinPlayers then  

		Shine:Notify( Client, "", "", "Waiting on Captain vote to finish.")

	end 
	
	return false

end 

function Plugin:Vote()

	return false

end

function Plugin:Spectator()

	return false

end

function Plugin:Choose( Client )
	
	local ClientId = Client:GetUserId()
	local Captain = Plugin:CaptainStatus( ClientId )
	local Current = CurrentCaptain( ClientId )

	if Captain and Current then
	
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")

	elseif Captian and not Current then 

		Shine:Notify( Client, "", "", "You are not the current captain.")

	elseif not Captain then 
		
		Shine:Notify( Client, "", "", "You have to be a captain to choose teams...")
	end

	return false

end

function Plugin:Ready( Client )

	local ClientId = Client:GetClientId() 
	local Readied = Plugin.Readied( clientId )
	local Full = AtCapacity()	
	
	if not Full and not Readied then

		Shine:Notify( Client, "", "", "You have joined the Pug! Wait for Captain Vote.")

		return true 

	elseif Readied then
 		
		Shine:Notify( Client, "", "", "You have already joined the pug. Type !unready to leave or !vote to vote for your team captain.") 

	elseif Full then 
	
		Shine:Notify( Client, "", "", "The pug is full. Please wait for the next one to start and then ready.") 
	end

	return false
end

function Plugin:ClientDisconnect( Client ) 

	remove[	Plugin.Readied[ Client:GetUserId() ] ] and FixArray( Plugin.Readied )  

	remove[ Plugin.Captain[ Client:GetUserId() ] ] and FixArray( Plugin.Captain )
	
	remove[ Plugin.Voted[ Client:GetUserId() ] ] and FixArray( Voted.Captain )

	remove[ Plugin.Spectator[ Client:GetUserId() ] ] and FixArray( Spectator.Captain )

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
