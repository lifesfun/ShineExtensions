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
    PugMode = true, -- Enabled Pug Mode
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
Plugin.Voted = {}
Plugin.Votes = 0
Plugin.Teams = {}
Plugin.Captains = {}
Plugin.Captain = 0
Plugin.CurrentPick = nil
Plugin.Readied = {}
Plugin.Ready = 0
 
function Plugin:Initialise()
    	local GetMod = Server.GetActiveModId

	for i = 1, Server.GetNumActiveMods() do
        	local Mod = GetMod( i ):lower()

       		local OnBlacklist = BlacklistMods[ Mod ]
	
        	if OnBlacklist then
        	    return false, StringFormat( "The Pug plugin does not work with %s.", OnBlacklist )
       		end
    	end
    
        if self:CreateCommands() then Plugin:Nag() end

        self.Enabled = true

        return true
end

local NextStartNag = 0

function Plugin:CheckGameStart( Gamerules )

	local State = Gamerules:GetGameState()

	if self.Config.PugMode and Shared.GetEntitiesWithClassname("Player" ):GetSize() >= self.Config.MinPlayers then
		 
	end
	if State == kGameState.PreGame or State == kGameState.NotStarted then
	if NextStartNag < Time then
		NextStartNag = Time + 30
	
		local Nag = self:GetStartNag()
	
		if not Nag then return false end
		
		self:SendNetworkMessage( nil, "StartNag", { Message = Nag }, true )
	end
	
	return false
	end
end 

function Plugin:Nag()
  
end

function Plugin:CheckVotes(Client, Player )
    if self.Config.PugMode and Plugin.Voted >= MinPlayer then
	if not Plugin.Ready <= self.Config.GameSize and Plugin.Readied[Client:GetUserId()] == false then
		Shine:Notify( Client, "", "", "Pug Mode is enabled. Type !rdy to join the Pueggg!")
        	if not Plugin.Readied[Client:GetUserId()] then Plugin.Readied[Client:GetUserId()]= true Plugin.Readied = Plugin.Readied + 1 end
        elseif Plugin.Captains <= 2 and Plugin.Voted[Client:GetUserId()] == false then
		Shine:Notify( Client, "", "", "Time to choose your team captains. Type !vote followed by part of their player name to vote.")
        	if not Plugin.Voted[Client:GetUserId()] then Plugin.Voted[Client:GetUserId()]= true Votes = Votes + 1 end
        if self.Config.PugMode and Client:GetUserId() == CurrentPick and playersOnTeams <= self.Config.GameSize then
            local Player = player:GetPlayer()
            local playerTeam = Client:GetPlayer():GetTeam():GetTeamNumber()
            if playerTeam ~= 0 then Shine:Notify( Client, "", "", "You can only choose players from the Ready Room") return end
            Gamerules:JoinTeam( Player, playerTeam, nil, true )
        end
	--check which captain has won the vote  at the end of the vote time if statment + for statment 2 condidtions
	--add name to catpain list and captain online + if not greater 1
	elseif self.Config.PugMode and Client:GetUserId() == Plugin.CurrentPick and playersOnTeams <= self.Config.GameSize then
		Shine:Notify( Client, "", "", "Your turn...")
	end

    Shine:Notify( Client, "", "", "You have been chosen as a team captain. When it is your turn type !choose followed by their player name to pick your teammate.")
   end
return 0
end

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

    if Plugin.Voted[Client:GetUserId()] then Plugin.Voted[Client:GetUserId()]= nil Plugin.Votes = Plugin.Votes - 1 end   

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
    if self.Config.PugMode then        
        if self.Config.Captains[id] then
            self.Config.Teams[id] = NewTeam
            self:SaveConfig()            
        return end
    end    
    return false
end


function Plugin:CreateCommands()

    local Ready = self:BindCommand( "sh_ready", { "rdy", "ready" }, CheckVotes(Client, Player ) )
    	Ready:Help ("Join the Pug")
    
    local Vote = self:BindCommand( "sh_vote", { "vote" }, CheckVotes(Client, Player  ) )
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ("Type the name of the player to place him/her on your team.")
    
    local Choose = self:BindCommand( "sh_choose", { "choose" }, CheckVotes(Client, Player ) )
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ("Type the name of the player to place him/her on your team.")
    
    local Clearteams = self:BindCommand( "sh_clearteams", "clearteams", function()
        self.Config.Teams = {}
        self:SaveConfig()         
	end, true)
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
