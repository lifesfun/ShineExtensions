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

local Plugin = Plugin
Plugin.Version = "0.5"

Plugin.HasConfig = true
Plugin.ConfigName = "Pug.json"

Plugin.DefaultConfig = {

	PugMode = true, -- Enabled Pug Mode	
	
	TeamSize = 6, --Size of Team; if 0 the pug is based upon the # in the server  and still take there spot. 

	NagInterval = 0.3, --how often players are Nagged 

	VoteFinish = 0.6 --ratio of the game size to end the captain vote when; else waits until pug is full captains with the most votes wins

	VoteTimeout = 0.5, --length a captain has to choose a player until randomly assigned a player; 0 creates no timeout.

}

Plugin.CheckConfig = true

Plugin.Players = {} , {} --$1 is playerid , $2 are the playerids for who they voted for  

Plugin.MatchPlayers = {} --live list of matchplayers while the voting process is going on, in case of dissconnect

Plugin.Votes = {} -- live count of # of votes 
--voting is a type of rank based voting. Each vote is rank of your choice. Vote 1 is your first choice. If your first vote is not one of top voted or that member is a captain then your second choice is counted. 

Plugin.Captains {}  --The first top voted to join a team after the Pug is full or Vote is finished becomes a capain. 
--If that person leaves then the next highest voted will be put on a team i
--If the person leaves after the first choice the highest voted person on the team becomes the captain
--

--add rounds ? best of 3 etc or add to tournament mod actually
function Plugin:Initialise()

        if self:CreateCommands() and GameStarted == false then  
	
		self:Timer.Simple( self.Config.NagInterval function() 
			--Pick up game enabled!
			--Round will restart once two captains are voted upon
			self:GameStatus()
			self:PlaterStatus()
	
		end )
	
	end

        self.Enabled = true

        return true
end

function Plugin:StartGame()
	
	if self:Pug() == true then
	-- 	reset tournamentmode back on 
	--	add stats to true 
	--
	-- 	if enabled else
	--	rest game scores and etc
	--
	--	remove captains from voted
	--	removePlayer from queue on teams -- tracked by tournament mode
	--	start normal pregame
	--
		return true

	end

	return false

end 

function Plugin:Pug()

	local StartPug = self:StartedPug()
	local CheckVote
	local CheckPlayers
	local CaptainsOnTeams = self:CaptainsJoined()
	local CaptainsChoose = CapainsChoosed()
	
	if StartedPug == true and CaptainsOnTeams == true and CaptainsChoose == true and CheckPlayers == true then

		return true

	if Captains == 1 then  

		self:PugsStatus()

	if CaptainsJoined == false 

		Self:PugsStatus()

	if PugsFull == false then 
	
	elseif Self:CaptainsChoosed ==false then

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
--You are a captain

function UpdateMatchPlayers() 
	
	for Key, Value in ipairs( self.Players ) do 	
			
		if PugFull == false then
		
			MakeMatchPlayer( Value ) 

		elseif PugFull == true then
			--VotedCaptains 
			--else timer nag 

			return true

		end
	
	end 

	return false

end

function Plugin:MakeMatchPlayer( ClientId )

		if Plugin:InGame( ClientId ) then

			self.MatchPlayers[ Value ] = 0 	

			return true 

		end

end 

function Plugin:InGame( ClientId )
--search for clientId in game 
	if ClientId exits then  

		return true

	end

	return false 

end 


function Plugin:Vote( Client , VoteOne , VoteTwo )
	
--todo display vote

	if VotedCaptains == false and self.MatchPlayer[ Client:GetClientId() ] then 	
			
		--check if one or two exist as a matchplayer
		--Players[ClientId][1] = VoteOne
		--Players[ClientId][2] = VoteTwo

		self:VotedCaptains()
		Shine:Notify( Client, "", "", "You have voted for xxxx xxxx!" ) 
	
		return true

	end 
	
	return false

end

function VotedCaptains() 

	for _, Value in pairs( self:MatchPlayers() )  do
		
	
				
				Votes .i = 1
			if Votes.Value.i + 1 then

			elseif  Vote.VoteId ] == true then
			Vote.VoteId = Vote.VoteId + 1
	--create 1 or 2 captains depending on the vote amount
	--if two 
	--if the pug is full and vote timeout is done or votedamount is true for both captains then 
	
		 self:Timer.Simple( self.Config.NagInterval , function() self:CaptainsJoin() end )  

			--captains can now join teams you have naginterval seconds 
			-- return true
	--end

	end

	return false
end

function Plugin:PugsFull()
	
	if Count( self.MatchPlayers )  >= self.config.TeamSize * 2 then
		
	
		return true

	end

	return false

end

function SendToTeam( Client )

	if Client then 
		--send client to team

		return true
	
	else

		while clientexist do	

			local PlayerTeam = self.Player[ ClientId ]  

			if not PlayerTeam == nil then
					--ClientId + PlayerTeam
					--
				return true

			end
		end
	
	end

	return false

end 

function Plugin:CaptainsJoined( Client )
		
		if Client then 

			local ClientId = Client:GetClientId()

			if self:VotedCaptain( Client ) == true and self:CurrentCaptain() == 2 then

				return true

			elseif self:VotedCaptain( CliendId ) == true and self:CaptainsChoose( ClientId ) then

				return true 
		
			end 

		elseif self:Timer >= config.Timout and self:CaptainsChoose( self:RandomCaptains() ) == true then

			return true

		end
	
	return false 
	
end

function Plugin:CurrentCaptain( ClientId )

	local TeamOne = Team1.Size

	local TeamTwo = Team2.Size

	local MaxSize = self.Config.TeamSize

	if ClientId then 
	
		if TeamOne < TeamTwo and SizeOne < MaxSize and ClientId ==  self.Captain[1] then

			return true
		 
		elseif ClientID and TeamOne < TeamTwo and SizeTwo < MaxSize and ClientId == self.Captain[2] then

			return true

		end

	elseif ClientID == nil then 
	
		return Count( self.Captain )  

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

function Plugin:Choose( Client , PlayerId )

	local CurrentCaptain = self:CurrentCaptain( Client:GetClientId() ) 

	if CurrentCaptain == true then	

		--send user to team	
		--
		Shine:Notify( Client, "", "", "Nice choice.. or hopefully it was. Please wait for your next turn.")

		--Getclient:CurrentCaptain Captain: It is your turn to pick

		return true
		
	elseif CurrentCaptain == false then 

		Shine:Notify( Client, "", "", "You are not the current Captain." )

	end 

	return false

end
	
function OnConnect()

	if Players[#Players+1] = CliendId
	if Pugsfull == false then 	

	if self:PugsStarted() == false and self:CheckPlayers() 
	if self:PugsStarted() and self:CheckMatch() then 
	if self:PugsFull then
		self: 
end

function RandomCaptains() --randomchooses a team for the captains
function RandomPlayer() --chooses a random player from the readroom
function CheckExists() --find if player exists and returns userid
--on disconnect
--Needplayers
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

    local Vote = self:BindCommand( "sh_vote", { "vote" }, CheckVotes( Client , Player  ) )

    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )
    
    local Choose = self:BindCommand( "sh_choose", { "choose" } , Choose( Client , Team ) )
    			
    	Choose:AddParam{ Type = "client"}    
    	Choose:Help ( "Type the name of the player to place him/her on your team." )

    local Ready = self:BindCommand( "sh_assign" , { "assign" } , CheckVotes( Client ) )

    	Ready:Help ( "Assigns Player to a team" )
    
end

function Plugin:Cleanup()

	self.BaseClass.Cleanup( self )
	self.Enabled = false

end

Shine:RegisterExtension( "pug", Plugin )
