--[[
Shine Pug Plugin 
]]
--[[
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

	MinPlayers = 8 , 
	GameSize = 12 ,
	VoteLength = 30 ,
	ChooseLength = 30 ,
	NagInterval = 20 ,
	
	Rounds = 2

}

Plugin.CheckConfig = true

Plugin.Rounds = { 

	Team { 

		Group = '@readyroom',
	
	}

}
		
Plugin.MatchPlayers = {

		Team = 0 , 
		Captain = 0 , 
		VotedCapt = 0 

}

function Plugin:Initialise()
   	--check rounds from mapvote and override  
        if self:CreateCommands() then Plugin:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	--if gamestatus and no started  then  
	--	rest game scores and etc
	--	startwarmup
	--	subtract round 
	--	add stats to true 
	--	return true
	--if not gamesatus and ready 
	--	place on teams 
	--	send message 
	--	startgame() 
	--else 
	--	 nag 
	--end
end 
function endgame()
	--if rounds != 0
	--then switch teams reset and start warmup
	--else reset all arrays reset pu
	--StartGame

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

	local NumPlayers = Count( Plugin.MatchPlayers )

	if NumPlayers < self.Config.GameSize then 
	
		return false 
	
	else 
	
		return true 

	end 

end

function Readied( CliendId )

 --function( ClientId )if Plugin.MatchPlayers[ ClientId ] then return true else return false end end
end 

function Plugin:NagCaptain( Client ) 

end
function Plugin:CaptainStatus( ClientId )

end

function Plugin:CurrentCaptain( ClientId )

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

end 

function Plugin:Choose( Client )
	
	local ClientId = Client:GetUserId()
	local Captain = Plugin:CaptainStatus( ClientId )
	local Current = CurrentCaptain( ClientId )

	if Captain and Current then
	
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")
		return true 

	elseif Captian and not Current then 

		Shine:Notify( Client, "", "", "You are not the current captain.")
		return false

	elseif not Captain then 
		
		Shine:Notify( Client, "", "", "You have to be a captain to choose teams...")
		return false 
	end

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
		return false 

	elseif Full then 
	
		Shine:Notify( Client, "", "", "The pug is full. Please wait for the next one to start and then ready.") 
		return false 

	else 
	
		return false

	end
end

function Plugin:ClientDisconnect( Client ) 

	remove[	Plugin.MatchPlayers[ Client:GetUserId() ] ] and FixArray( Plugin.MathPlayers )  

	remove[ Plugin.Captain[ Client:GetUserId() ] ] and FixArray( Plugin.Captain )
	
end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce )

	local Player = player:GetPlayer()
	local playerTeam = Client:GetPlayer():GetTeam():GetTeamNumber()

	if playerTeam ~= 0 then Shine:Notify( Client, "", "", "You can only choose players from the Ready Room") return end
            Gamerules:JoinTeam( Player, playerTeam, nil, true )

		local id= Player:GetClient():GetUserId()
    
    --block f4 if forceteams is true
		if self.Config.ForceTeams then

		if NewTeam == kTeamReadyRoom then return false end 

	end 
    
    --cases in which jointeam is not limited
	if not self.Config.PugMode or ShineForce then

        	self.Config.Teams[id] = NewTeam
        	self:SaveConfig()

	return 

	end
    
    --check if player is Captain
	if self.Config.PugMode then        

		if self.Config.Captains[id] then

			self.Config.Teams[id] = NewTeam
			self:SaveConfig()            

			return

		end

	end    

	return false

end

function Plugin:CreateCommands()

    local Ready = self:BindCommand( "sh_ready" , { "rdy" , "ready" } , CheckVotes( Client ) )

    	Ready:Help ( "Join the Pug" )
    
    local Ready = self:BindCommand( "sh_unready" , { "unrdy" , "unready" } , CheckVotes( Client ) )

    	Ready:Help ( "Join the Pug" )

    local Vote = self:BindCommand( "sh_vote", { "vote" }, CheckVotes( Client , Player  ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
    local Choose = self:BindCommand( "sh_choose", { "choose" } , CheckVotes( Client , Player ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
    local Clearteams = self:BindCommand( "sh_clearteams" , "clearteams" , function()

	        self.Config.Teams = {}
       		self:SaveConfig()         

	end , true )

   	Clearteams:Help( "Removes all players from teams in config" )

end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
