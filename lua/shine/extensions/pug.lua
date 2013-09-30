--[[
Shine Pug Plugin 
]]

local Shine = Shine
local Timer = Shine.Timer


local Notify = Shared.Message

local Plugin = Plugin
Plugin.Version = "0.1"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"
Plugin.DefaultConfig = {
    PugMode = true, -- Use Captain Mode
    ForceTeams = false, --force teams to stay the same
    MinPlayers = 8   
    GameSize = 12
    CaptainVoteLength = 30
}

Plugin.CheckConfig = true

--List of mods not compatible with tournament mode
local BlacklistMods = {
        [ "7e64c1a" ] = "Xenoswarm",
        [ "6ed01f8" ] = "The Faded"
}

//saves Votes
local Voted = {}
local Votes = 0
local Teams = {}
local Captains = {}
local Captain = 0
local CurrentPick = nil
local Ready = {}
local Readied = 0
 
function Plugin:Initialise()
    	local GetMod = Server.GetActiveModId

	for i = 1, Server.GetNumActiveMods() do
        	local Mod = GetMod( i ):lower()

       		local OnBlacklist = BlacklistMods[ Mod ]
	
        	if OnBlacklist then
        	    return false, StringFormat( "The Pug plugin does not work with %s.", OnBlacklist )
       		end
    	end
    
        self:CreateCommands()

        self.Enabled = true

        return true
end

function Plugin:Nag()
    
	if not Shared.GetEntitiesWithClassname( "Player" ):GetSize() >= self.Config.MinPlayers and self.Config.PugMode then 
		
        elseif Captains <= 1 then
			Shine:Notify( Client, "", "", "Pick your captian by typing into the chat: !captain <playername>") 
	elseif self.Captains[id] == true then 
		Shine:Notify( Client, "", "", "Your are a team captain! Choose your teammates with !choose\n Type !rdy into chat when you are ready.")
	else Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy into chat if you want to join the pug.")

	--check which captain has won the vote  at the end of the vote time if statment + for statment 2 condidtions
	--add name to catpain list and captain online + if not greater 1
	end
end

function Plugin:Check Votes
    
	if self.  then 
		
        elseif Captains <= 1 then
			Shine:Notify( Client, "", "", "Pick your captian by typing into the chat: !captain <playername>") 
	elseif self.Captains[id] == true then 
		Shine:Notify( Client, "", "", "Your are a team captain! Choose your teammates with !choose\n Type !rdy into chat when you are ready.")
	else Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy into chat when you are ready")





function Plugin:StartGame( Gamerules )
    Gamerules:ResetGame()
    Gamerules:SetGameState( kGameState.Countdown )
    Gamerules.countdownTime = kCountDownLength
    Gamerules.lastCountdownPlayed = nil

    for _, Player in ientitylist( Shared.GetEntitiesWithClassname( "Player" ) ) do
        if Player.ResetScores then
            Player:ResetScores()
        end
    end
end
    
function Plugin:ClientDisconnect(Client)

    if Voted[Client:GetUserId()] then Voted[Client:GetUserId()]= nil Votes = Votes -1 end   

end

--[[
	Block players from joining teams in Pug mode
]]
function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force, ShineForce )
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
    if self.Config.PugnMode then        
        if self.Config.Captains[id] then
            self.Config.Teams[id] = NewTeam
            self:SaveConfig()            
        return end
    end    
    return false
end


function Plugin:CreateCommands()

    	local Ready = self:BindCommand( "sh_ready", {"rdy","ready"},function(Client)
        if self.Config.PugMode and Readied <= self.Config.GameSize then
        	if not Ready[Client:GetUserId()] then Ready[Client:GetUserId()]= true Readied = Readied + 1 end
        end
        Plugin:CheckVotes
    end, true)
    Ready:Help ("Join the Pug")
    
    local Captain = self:BindCommand( "sh_captain","captain" ,function(Client, player)
        if self.Config.PugMode and Readied = self.Config.MinPlayers and not self.Config.Captains[Client:GetUserId()] then
        	if not Voted[Client:GetUserId()] then Voted[Client:GetUserId()]= true Votes = Votes + 1 end
        end
        Plugin:CheckVotes
    end,true)
    Choose:AddParam{ Type = "client"}    
    Choose:Help ("Type the name of the player to place him/her on your team.")
    
    local Choose = self:BindCommand( "sh_choose","choose" ,function(Client, player)
        if self.Config.PugMode and Client:GetUserId() == CurrentPick and playersOnTeams <= self.Config.GameSize then
            local Player = player:GetPlayer()
            local playerTeam = Client:GetPlayer():GetTeam():GetTeamNumber()
            if playerTeam ~= 0 then Shine:Notify( Client, "", "", "You can only choose players from the Ready Room") return end
            Gamerules:JoinTeam( Player, playerTeam, nil, true )
        end
    end,true)
    Choose:AddParam{ Type = "client"}    
    Choose:Help ("Type the name of the player to place him/her on your team.")
    
    local Clearteams = self:BindCommand( "sh_clearteams","clearteams" ,function()
        self.Config.Teams = {}
        self:SaveConfig()        
    end)
    Clearteams:Help("Removes all players from teams in config ")
end

function Plugin:Cleanup()
	self.BaseClass.Cleanup( self )
        
	self.TeamMembers = nil
        self.ReadyStates = nil
        self.TeamNames = nil
	
	self.Enabled = false
end

Shine:RegisterExtension( "tournamentmode", Plugin )
