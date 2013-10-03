--[[
Shine Pug Plugin 
]]

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
	MinPlayers = 8   
	GameSize = 12

	VoteLength = 30
	ChooseLength = 10	
}

Plugin.CheckConfig = true

Plugin.Readied = {}
Plugin.Voted = {}
Plugin.Captains = {}
Plugin.CurrentPick = nil
Plugin.Teams = {}
 
function Plugin:Initialise()
    
        if self:CreateCommands() then Plugin:StartGame() end

        self.Enabled = true

        return true
end

function Plugin:Nag()

	
		Plugin:Timer.Simple( 20 , function() 
		
			Plugin:NagMessage()
			 		
			local State = Gamerules:GetGameState()
			
			if not State ~= kGameState.Started then Plugin:NagMessage() end
			
		end )
		
		 
function NagMessage( Client )

	if Plugin.Captain[ Client ] then
 
    		Shine:Notify( Client, "", "", "You have been chosen as a team captain. When it is your turn type !choose followed by their player name to pick your teammate.")
		Shine:Notify( Client, "", "", "Your turn to choose...")
		Shine:Notify( Client, "", "", "Waiting on more players to join.")
		Shine:Notify( Client, "", "", "You have choosen, waiting on other captain.")

	elseif Plugin.Voted[ Client ] then 
		
		
			Shine:Notify( Client, "", "", "Teams are being chosen")
			
			Shine:Notify( Client, "", "", "You have voted. Waiting on other players to finish voting.")
		
	elseif  Plugin.Readied[ Client ] then 
		 
		Shine:Notify( Client, "", "", "Waiting on more players to join the pug.")

		Shine:Notify( Client, "", "", "Time to choose your team captains. Type !vote followed by part of their player name to vote.")

	else 
	 
		Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy to join the Pueggg!")

	end

end


function Vote()

	Plugin.Voted >= MinPlayer 
	Plugin.Ready <= self.Config.GameSize and Plugin.Readied[Client:GetUserId()] == false 
	Plugin.Readied[Client:GetUserId()] and Plugin.Readied[Client:GetUserId()]= true 
	Plugin.Captains <= 2 and Plugin.Voted[Client:GetUserId()] == false 
	Plugin.Voted[Client:GetUserId()] and Plugin.Voted[Client:GetUserId()]= true 
	Client:GetUserId() == CurrentPick and playersOnTeams <= self.Config.GameSize 
	Client:GetUserId() == Plugin.CurrentPick and playersOnTeams <= self.Config.GameSize 

end


function Plugin:ClientDisconnect(Client) 

		Plugin.Readied[ Client:GetUserId() ]  
		
		Plugin.Voted[ Client:GetUserId() ] - 

		Plugin.Captain[ Client:GetUserId() ]  
	end
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
    return end
    
    --check if player is Captain
    if self.Config.PugMode then        
        if self.Config.Captains[id] then
            self.Config.Teams[id] = NewTeam
            self:SaveConfig()            
        return end
    end    
    return false
end


function Plugin:CreateCommands()

    local Ready = self:BindCommand( "sh_ready" , { "rdy" , "ready" } , CheckVotes( Client ) )
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
        
	self.TeamMembers = nil
        self.ReadyStates = nil
        self.TeamNames = nil
	
	self.Enabled = false
end

Shine:RegisterExtension( "tournamentmode", Plugin )
