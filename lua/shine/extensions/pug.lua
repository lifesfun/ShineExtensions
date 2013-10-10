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
    
        if self:CreateCommands() then Plugin:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:Nag()

	Plugin:Timer.Simple( self.Config.NagInterval , function() 
		Plugin:StartGame()
			
	end )
end

function Plugin:StartGame()
	--basics	
	--
	if then

	else
	
		Plugin:Nag()

	end

end 

function Plugin:GameStatus(Client)

	local Readied = Plugin:Count( Plugin.Match ) 
	
	local ClientId = Client:GetUserId()

	if Readied  <  self.Config.MinPlayers then
		
		if Plugin:MatchPlayers[ Client ] == true then

			Shine:Notify( Client, "", "", "Waiting on more players to join the pug to start the captain vote.")
		else

			Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy to join the Pueggg!")
		end

	elseif Readied >=  self.Config.GameSize or Plugin.CaptainStatus() == true then
		--check captain pick status
		--captains 
		--captainmode
		--else
		--check game gamestarted warmup pregame	
		--check missing players
		--started
	else

		Shine:Notify( Client, "", "", "Waiting on the pug to fill, so captains can pick teams.")

	end

end

function Plugin:VoteStatus( Client )

	if Plugin.Captain[ Client ] then

    		Shine:Notify( Client, "", "", "Waiting on Captain vote to finish.")
		
		return "captain"

	elseif Plugin.Voted[ Client ] then 

    		Shine:Notify( Client, "", "", "Waiting on Captain vote to finish.")
		
		return "Voted"

	elseif Plugin.Readied[ Client ] then 

		Shine:Notify( Client, "", "", " Captain Vote has started. Type !vote followed by part of their player name to vote.")
		
		return "readied"
	else 
		Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy to join the Pueggg!")
		
		return false
	end

end

function Plugin:CaptainsStatus( Client )			

	if Plugin.Captain[ Client:GetUserId() ] ~=  Plugin.CurrentCaptain then

		Shine:Notify( Client, "", "", "You have choosen, waiting on other captain.")
		return Plugin.CurrentCaptain

	elseif Count( Plugin.Captain[] )== 2  then

		Shine:Notify( Client, "", "", "Your turn to choose...")
		return "onecaptain"
	else
		
		Shine:Notify( Client, "", "", "Waiting on more players to pick teams to pick teams.")
		return false
	end

end

function Plugin:Choose( Client )
	
	local ClientId = Client:GetUserId()

	if Plugin.CaptainStatus[ ClientId ] ==  true then
	
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")
		return true 

	elseif Plugin:CaptainStatus[ ClientId ] == false then 

		Shine:Notify( Client, "", "", "You have to be a captain to choose teams...")
		return false

	else
		
		Shine:Notify( Client, "", "", "You are not the current captain.")
		return false 
	end

end

function Plugin:Vote( Client )

	local ClientId = Client:GetUserId()

	if Plugin:VoteStatus( ClientId ) == false and Plugin:CaptainStatus( ClientId ) == false then 	

		Shine:Notify( Client, "", "", "Thanks for voting! Please wait to be assigned to a team.") 
		return true 

	elseif Plugin:CaptainStatus( ClientId )  == true then

		Shine:Notify( Client, "", "", "You are a captain now and are not allowed to vote for the second captain.")
		return false

	elseif Plugin.Voted[ ClientId ] == true then 

		Shine:Notify( Client, "", "", "You have already voted.")
		return false

	elseif  Plugin:ReadyStatus( ClientId )  == false then

		Shine:Notify( Client, "", "", "You have not joined the Pug yet. Type !rdy to join the Pueggg!")
		return false

	else
		
		return false

	end

end

function Plugin:Ready( Client )

	local ClientId = Client:GetClientId() 
	
	local Full = function() if Count( Plugin.MatchPlayers ) < self.Config.GameSize then return false else return true end end  
	
	if Full == false and Plugin.MatchPlayers[ ClientId ] then

		Shine:Notify( Client, "", "", "You have joined the Pug! Wait for Captain Vote.")
		return true 

	elseif Plugin.MatchPlayers[ ClientId ] == true then
 		
		Shine:Notify( Client, "", "", "You have already joined the pug. Type !unready to leave or !vote to vote for your team captain.") 
		return false 

	elseif Full == true then 
	
		Shine:Notify( Client, "", "", "The pug is full. Please wait for the next one to start and then ready.") 
		return false 

	else 
	
		return false

	end
end

function Plugin:ClientDisconnect( Client ) 

	remove[	Plugin.MatchPlayers[ Client:GetUserId() ] ] and FixArray( Plugin.MathPlayers )  

	remove[ Plugin.Captain[ Client:GetUserId() ] ]  and FixArray( Plugin.Captain )
	
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
