local Plugin = Plugin
Plugin.Version = "1.0"

Plugin.HasConfig = true 
Plugin.ConfigName = "PregamePlus.json"

Plugin.DefaultConfig = {
   EnablePGP = true,
   CheckLimit = true,
   PlayerLimit = 8,
   LimitToggleOffDelay = 20,
   LimitToggleOnDelay = 45,
}

Plugin.CheckConfig = true
Plugin.DefaultState = true


--table of all the extra entities we made for PGP
--used to removed them in Plugin:SetGameState
Plugin.NewEnts = nil

--holds the time when PGP should turn off due to player limit
Plugin.PlyrLimEndTime = nil

--holds the time when PGP should turn on due to lack of players
Plugin.PlyrLimEnableTime = nil

--Giving the "PGP on" msg a delay otherwise if it was 
--immediately turned off, it would still say pgp is on
Plugin.ResetNoticeTime = math.huge
local ResetNoticeDelay = 2

--used to set camera distance when forcing respawn
local kFirstPerson = 0




local SetupClassHook = Shine.Hook.SetupClassHook
local SetupGlobalHook = Shine.Hook.SetupGlobalHook




-- lets you jump into empty exosuits during PGP
-- not under Modified NS2 funcs because its not defined
function Exosuit:GetUseAllowedBeforeGameStart()
   if Plugin.dt.PGP_On then return true end
   return false
end

















-- ============================================================================
-- =                          Auxiliary Functions                             =
-- ============================================================================


-- returns whether we are at or over the player limit
-- We aren't counting ready room or spectate players to ensure we don't turn
-- off PGP unless we can get a match of at least PlayerLimit people.
local function AtPlayerLimit(ns2rules)
   local MarineCount = ns2rules:GetTeam1():GetNumPlayers()
   local AlienCount = ns2rules:GetTeam2():GetNumPlayers()
   return MarineCount + AlienCount >= Plugin.Config.PlayerLimit
end


-- returns true if there is an alien and marine commander
local function HasBothComms(ns2rules)
   local HasMarineComm = ns2rules:GetTeam1():GetHasCommander()
   local HasAlienComm = ns2rules:GetTeam2():GetHasCommander()
   return HasMarineComm and HasAlienComm
end



local function NotifyR( Player, Prefix, String, Format, ... )
   Shine:NotifyDualColour( Player, 255, 000, 000, Prefix, 
                                   255, 255, 255, String, Format, ... )
end



local function NotifyG( Player, Prefix, String, Format, ... )
   Shine:NotifyDualColour( Player, 000, 255, 000, Prefix, 
                                   255, 255, 255, String, Format, ... )
end



-- checks whether PGP should be turned
-- off based on the amount of players
local function CheckAtPlyrLim(ns2rules)
   --turn off PGP if passed timer and enough players
   if AtPlayerLimit(ns2rules) then 
      local limit = Plugin.Config.PlayerLimit
      if Plugin.PlyrLimEndTime then
         if Shared.GetTime() >= Plugin.PlyrLimEndTime then
            local OffMsg = "Turned off due to player limit (%d)."
            NotifyR(nil, "[PGP off]", OffMsg, true, limit)
            ns2rules:ResetGame()
            Plugin.PlyrLimEndTime = nil
         end
      else
         --at player limit but no timer, start it
         local delay = Plugin.Config.LimitToggleOffDelay
         local WarnMsg = "Player limit (%d) reached; turning off in %ds."
         NotifyR(nil, "[PGP mod]", WarnMsg, true, limit, delay )
         Plugin.PlyrLimEndTime = Shared.GetTime() + delay
      end
   else
      --if the timer ends  and under player limit, turn off timer
      local EndTime = Plugin.PlyrLimEndTime
      if EndTime and Shared.GetTime() >= EndTime then
         Plugin.PlyrLimEndTime = nil
      end
   end
end



--checks whether PGP should be turned on based on the amount of players
local function CheckUnderPlyrLim(ns2rules)
   --turn on PGP if passed timer, not enough players, and no match
   if HasBothComms(ns2rules) then return end
   if ns2rules:GetGameState() ~= kGameState.NotStarted then return end
   
   if not AtPlayerLimit(ns2rules)then
      if Plugin.PlyrLimEnableTime then
         if Shared.GetTime() >= Plugin.PlyrLimEnableTime then
            ns2rules:ResetGame()
            Plugin.PlyrLimEnableTime = nil
         end
      else
         --under player limit but no timer, start it
         local delay = Plugin.Config.LimitToggleOnDelay
         local limit = Plugin.Config.PlayerLimit
         local WarnMsg = "Under player count (%d); turning on in %ds."
         NotifyG(nil, "[PGP mod]", WarnMsg, true, limit, delay )
         Plugin.PlyrLimEnableTime = Shared.GetTime() + delay
      end
   else
      --if the timer ends and at player limit, turn off timer
      local EnableTime = Plugin.PlyrLimEnableTime
      if EnableTime and Shared.GetTime() >= EnableTime then
         Plugin.PlyrLimEnableTime = nil
      end
   end

end



--oh god it reproduces
--hooks functions onto a player and its potential children
--when called, it hooks onto the player's replace function with itself
--so any children of this object will also have the contained hooks
local function PGPReplace(thePlayer)

   --lets us sidestep the condition for a started game 
   --and let's us buy stuff during pregame
   local oldProcessBuy = thePlayer.ProcessBuyAction

   local function NewProcessBuy(theAlien, techIds)
      if Plugin.dt.PGP_On then
         local ns2rules = GetGamerules()
         ns2rules.gameState = kGameState.Started
         oldProcessBuy(theAlien, techIds)
         ns2rules.gameState = kGameState.NotStarted
      else
         oldProcessBuy(theAlien, techIds)
      end
   end
   
   thePlayer.ProcessBuyAction = NewProcessBuy
   
   
   
   --making exo ejecting not check if game has started
   local oldGetIsPlaying = thePlayer.GetIsPlaying
   thePlayer.GetIsPlaying = 
      function (thePlayer) 
         if Plugin.dt.PGP_On then return thePlayer:GetIsOnPlayingTeam() end
         return oldGetIsPlaying(thePlayer)
      end
   
   

   --hooks onto its children's Replace function like a genetic disease
   local oldReplace = thePlayer.Replace

   local function NewReplace(...)
      local newPlayer = oldReplace(...)
      if Plugin.dt.PGP_On then PGPReplace(newPlayer) end
      return newPlayer
   end

   thePlayer.Replace = NewReplace
end



--sets all the player's res back to their initial res
local function ResetTeamRes(theTeam)
   if theTeam:GetNumPlayers() > 0 then 
      theTeam:ForEachPlayer( function (thePlayer)
         thePlayer:SetResources(kPlayerInitialIndivRes)
         end
      )
   end
   
   local teamComm = theTeam:GetCommander()
   if teamComm then 
      teamComm:SetResources(kCommanderInitialIndivRes)
   end
end



--creates entities around a tech point
local function MakeTechEnt(techPoint, mapName, rightOffset, 
                             forwardOffset, teamType)
   local origin = techPoint:GetOrigin()
   local right = techPoint:GetCoords().xAxis
   local forward = techPoint:GetCoords().zAxis
   local position = origin+right*rightOffset+forward*forwardOffset  
   
   local newEnt = CreateEntity( mapName, position, teamType)
   if HasMixin(newEnt, "Construct") then newEnt:SetConstructionComplete() end
   
   table.insert(Plugin.NewEnts, newEnt)
end


-- ============================================================================
-- ============================================================================
















-- ============================================================================
-- =                         Modified NS2 Functions                           =
-- ============================================================================
-- These functions hook onto existing NS2 functions and add functionality onto
-- them. These functions should only execute additional code if PGP_On == true,
-- with the exception of ResetGame and OnUpdate who regulate the mod.
-- ----------------------------------------------------------------------------



-- ------------------------------  Alien Stuff  -------------------------------


-- instantly spawn dead aliens
SetupClassHook( "AlienTeam", "Update", "AlTeamUpdate", "PassivePost")
function Plugin:AlTeamUpdate(AlTeam, timePassed)
   if Plugin.dt.PGP_On then
      local alienSpectators = AlTeam:GetSortedRespawnQueue()
      for i = 1, #alienSpectators do
         local spec = alienSpectators[i]
         AlTeam:RemovePlayerFromRespawnQueue(spec)
         local success, newAlien = AlTeam:ReplaceRespawnPlayer(spec, nil, nil)
         newAlien:SetCameraDistance(kFirstPerson)
      end
   end
end



-- client HUD will not update for alien traits without this
SetupClassHook( "AlienTeamInfo", "OnUpdate", "AlTeamOnUpdate", "PassivePost")
function Plugin:AlTeamOnUpdate(AlTeamInfo, deltaTime)
   if Plugin.dt.PGP_On then
      AlTeamInfo.veilLevel = 3
      AlTeamInfo.spurLevel = 3
      AlTeamInfo.shellLevel = 3
   end
end



-- set all evolution times to 1 second
SetupClassHook("Embryo", "SetGestationData", "SetGestationData", "PassivePost")
function Plugin:SetGestationData(TheEmbryo, techIds, previousTechId,
                                 healthScalar, armorScalar)
   if Plugin.dt.PGP_On then TheEmbryo.gestationTime = 1 end
end



-- set the biomass for the alien team
SetupClassHook( "AlienTeam", "UpdateBioMassLevel", 
                "UpdateBioMassLevel", "PassivePost")
function Plugin:UpdateBioMassLevel(AlTeam)
   if Plugin.dt.PGP_On then
      AlTeam.bioMassLevel = 9
      AlTeam.maxBioMassLevel = 9
   end
end








-- -----------------------------  Marine Stuff  -------------------------------



--prevents placing dead marines in IPs so we can do instant respawn
SetupClassHook("InfantryPortal", "FillQueueIfFree", "FillQueueIfFree", "Halt")
function Plugin:FillQueueIfFree(TheIP)
   if Plugin.dt.PGP_On then return "derp" end
end



-- immobile macs so they don't get lost on the map
SetupClassHook("MAC", "GetMoveSpeed", "MACGetMoveSpeed", "ActivePre")
function Plugin:MACGetMoveSpeed(TheMAC)
   if Plugin.dt.PGP_On then return 0 end
end



-- lets players use macs to instant heal since the immobile mac
-- cannot move, it may get stuck trying to weld distant objects
SetupClassHook("MAC", "OnUse", "MACOnUse", "PassivePost")
function Plugin:MACOnUse(TheMAC, player, elapsedTime, useSuccessTable)
   if Plugin.dt.PGP_On then player:AddHealth(999, nil, false, nil) end
end



-- spawns the armory, proto, armslab and 3 macs
-- A3, W3 set to researched to affect marine HUD
SetupClassHook("MarineTeam", "SpawnInitialStructures", 
               "MarSpawnInitialStructures", "PassivePost")
function Plugin:MarSpawnInitialStructures(MarTeam, techPoint)
   if not Plugin.dt.PGP_On then return end
   
   --don't spawn them if cheats is on(it already does it)
   if not (Shared.GetCheatsEnabled() and MarineTeam.gSandboxMode) then
      MakeTechEnt(techPoint, AdvancedArmory.kMapName, 3.5, 1.5, kMarineTeamType)
      MakeTechEnt(techPoint, PrototypeLab.kMapName, 3.5, -1.5, kMarineTeamType)
   end
   
   MakeTechEnt(techPoint, ArmsLab.kMapName, 3.5, 1.5, kMarineTeamType)
   
   for i=1, 3 do
      MakeTechEnt(techPoint, MAC.kMapName, -3.5, -1.5, kMarineTeamType)
   end   
   
   local techTree = MarTeam:GetTechTree()
   if techTree then
      techTree:GetTechNode(kTechId.Armor3):SetResearched(true)
      techTree:GetTechNode(kTechId.Weapons3):SetResearched(true)
   end
      

end



-- instantly respawn dead marines
SetupClassHook("MarineTeam", "Update", "MarTeamUpdate", "PassivePost")
function Plugin:MarTeamUpdate(MarTeam, timePassed)
   if Plugin.dt.PGP_On then
      local specs = MarTeam:GetSortedRespawnQueue()
      for i = 1, #specs do
         local spec = specs[i]
         MarTeam:RemovePlayerFromRespawnQueue(spec)
         local success,newMarine = MarTeam:ReplaceRespawnPlayer(spec, nil, nil)
         newMarine:SetCameraDistance(kFirstPerson)
      end
   end
end








-- ------------------------------  Score Stuff  -------------------------------
-- Preventing score from updating during PGP so it feels less like a real game
-- Scores are reset in JoinTeam if PGP is on since it does not on a game end



SetupClassHook( "ScoringMixin", "AddAssistKill", "AddAssistKill", "ActivePre")
function Plugin:AddAssistKill()
   if Plugin.dt.PGP_On then return "derp" end
end



SetupClassHook( "ScoringMixin", "AddKill", "AddKill", "ActivePre")
function Plugin:AddKill()
   if Plugin.dt.PGP_On then return "derp" end
end



SetupClassHook( "ScoringMixin", "AddDeaths", "AddDeaths", "ActivePre")
function Plugin:AddDeaths()
   if Plugin.dt.PGP_On then return "derp" end
end



SetupClassHook( "ScoringMixin", "AddScore", "AddScore", "ActivePre")
function Plugin:AddScore(points, res, wasKill)
   if Plugin.dt.PGP_On then return "derp" end
end









-- -----------------------------  General Stuff  ------------------------------



-- disables damage on structures except the gorge built ones
-- note: clogs don't have a Construct mixin
-- disables damage on the macs
SetupGlobalHook( "CanEntityDoDamageTo", "CanEntityDoDamageTo", "ActivePre" )
function Plugin:CanEntityDoDamageTo(attacker, target, cheats, devMode,
                                    friendlyFire, damageType)
   if Plugin.dt.PGP_On then
      if target:isa("Hydra") or target:isa("TunnelEntrance") then
         if attacker:isa("Alien") then return false end
         return true
      end
      
      if HasMixin(target, "Construct") then return false end
      if target:isa("MAC") then return false end
      
      local gameinfo = GetGameInfoEntity()
      Plugin.oldGameInfoState = gameinfo:GetState()
      GetGameInfoEntity():SetState(kGameState.Started)
   end
end



--undoes the gameState change in CanEntityDoDamageTo
SetupGlobalHook( "CanEntityDoDamageTo", "PostCanDamage", "PassivePost" )
function Plugin:PostCanDamage(attacker, target, cheats, devMode,
                                    friendlyFire, damageType)
   if Plugin.dt.PGP_On then
      GetGameInfoEntity():SetState(Plugin.oldGameInfoState)
   end
end



-- make evolutions/upgrades/equipment cost 0 res
-- this doesn't affect the client hud so we give them
-- 100 res in JoinTeam and ResetGame
SetupGlobalHook( "LookupTechData", "LookupTechData", "ActivePre" )
function Plugin:LookupTechData(techId, fieldName, default)
   if Plugin.dt.PGP_On then
      if fieldName == kTechDataUpgradeCost or
         fieldName == kTechDataCostKey then
         return 0
      end
   end
end



--runs the old join team and passes the new player to the plugin hook
local function JoinTeamReturn( OldFunc, ... )
   local success, newPlayer = OldFunc( ... )
   return Shine.Hook.Call("PGPJoinTeam", success, newPlayer, ...)
end
SetupClassHook( "NS2Gamerules", "JoinTeam", "PGPJoinTeam", JoinTeamReturn)

-- gives 100 res so player client lets them to buy stuff
-- if they join while PGP is on, notify them
function Plugin:PGPJoinTeam(success, newPlayer, ns2rules, player, newTeamNumber, force)
   if Plugin.dt.PGP_On then
      newPlayer:SetResources(100)
      --do not notify them if they join the ready room
      if ns2rules:GetWorldTeam():GetTeamNumber() ~= newTeamNumber then
         local notice = "Type pgp_help in console for more info"
         NotifyG( newPlayer, "[PGP mod enabled]", notice)
         if newPlayer.ResetScores then newPlayer:ResetScores() end
         PGPReplace(newPlayer)
      end
   end
   return success, newPlayer
end



-- enables abilities/upgrades/equipment
-- enables adrenaline but GUI does not update without spurs
--    this is fixed in AlienTeamInfo:OnUpdate
SetupClassHook("TechTree", "GetHasTech", "TreeGetHasTech", "ActivePre")
function Plugin:TreeGetHasTech(tree, techId)
   if Plugin.dt.PGP_On then
      local TechNode = tree:GetTechNode(techId)
      if TechNode then
         if TechNode:GetIsResearch() or 
            TechNode:GetIsBuild() or 
            TechNode:GetIsSpecial() then
            return true 
         end
      end
   end
end



-- In the case we aren't started normally with 2 comms (e.g sh_forceroundstart)
-- Turning PGP_On = false disables most functions but we have to undo
-- persistent changes e.g added entities, tech tree changes
-- Thus far, all of these are changes made during ResetGame
function Plugin:SetGameState( Gamerules, NewState, OldState )
   if Plugin.dt.PGP_On and NewState ~= kGameState.NotStarted then
      Plugin.dt.PGP_On = false;
      
      local techTree = Gamerules:GetTeam1():GetTechTree()
      if techTree then
         techTree:GetTechNode(kTechId.Armor3):SetResearched(false)
         techTree:GetTechNode(kTechId.Weapons3):SetResearched(false)
      end
      
      ResetTeamRes(Gamerules:GetTeam1())
      ResetTeamRes(Gamerules:GetTeam2())
      
      --kill the structuress we made for maries
      for i=1, #Plugin.NewEnts do
         DestroyEntity(Plugin.NewEnts[i])
      end
      Plugin.NewEnts = {}
      
   end
end



-- The trigger for turning on PGP.
-- We only turn on if we are enabled, we don't have both comms,
-- and we are under the player limit (if it's enabled).
SetupClassHook( "NS2Gamerules", "ResetGame", "PreResetGame", "PassivePre")
function Plugin:PreResetGame(ns2rules)
   Plugin.dt.PGP_On = false;
   Plugin.PlyrLimEndTime = nil
   Plugin.PlyrLimEnableTime = nil
   Plugin.NewEnts = {}
   
   --must be true before resetting because ResetGame calls
   --MarineTeam:SpawnInitialStructures which adds our buildings
   if Plugin.Config.EnablePGP then
      if HasBothComms(ns2rules) then return end
      if AtPlayerLimit(ns2rules) and Plugin.Config.CheckLimit then return end
      
      Plugin.dt.PGP_On = true
   end
end



-- Initialization for the mod after a reset, if it turns on
-- reset cleans these values so we must set them after
SetupClassHook( "NS2Gamerules", "ResetGame", "PostResetGame", "PassivePost")
function Plugin:PostResetGame(ns2rules)
   if not (Plugin.Config.EnablePGP and Plugin.dt.PGP_On) then return end

   --add res to all the players already on a team
   --only other time res is added is during team joining
   local marines = ns2rules:GetTeam1()
   if marines:GetNumPlayers() > 0 then 
      marines:ForEachPlayer(function (plyr) plyr:SetResources(100) end)
      marines:ForEachPlayer(PGPReplace)
   end
   
   local aliens = ns2rules:GetTeam2()
   if aliens:GetNumPlayers()> 0 then
      aliens:ForEachPlayer(function (plyr) plyr:SetResources(100) end)
      aliens:ForEachPlayer(PGPReplace)
   end
      
   Plugin.ResetNoticeTime = Shared.GetTime() + ResetNoticeDelay
      
end



-- detects whether PGP should be toggled off or on based pn player limit
SetupClassHook("NS2Gamerules", "OnUpdate", "NS2OnUpdate", "PassivePost")
function Plugin:NS2OnUpdate(ns2rules, timePassed)
   local config = Plugin.Config
   
   if not config.EnablePGP then return end
   if not config.CheckLimit then return end
   
   if Plugin.dt.PGP_On then
      CheckAtPlyrLim(ns2rules)
      if Shared.GetTime() >= Plugin.ResetNoticeTime then
         local notice = "This is a training mode."
         local help = "Type pgp_help in console for more info"
         NotifyG( nil, "[PGP on]", notice)
         NotifyG( nil, "[PGP on]", help)
         Plugin.ResetNoticeTime = math.huge
      end
   else
      CheckUnderPlyrLim(ns2rules)
   end

end


-- ============================================================================
-- ============================================================================
















-- ============================================================================
-- =                           Console Commands                               =
-- ============================================================================
local HelpTable = {
"\n",
"PGP provides an alternative to small matches for low population servers.",
"PGP allows players to practice or goof around before a real match starts.",
"While PGP is on players can buy/evolve into anything and fight each other.",
"PGP may turn off due to the # of players depending on the server's config.",
"You may check the server's current config values by typing pgp_config",
"If the MACs do not weld you, press your USE key on them to instantly heal.",
"For more info, visit the workshop page. Search for pregame shine."
}



function Plugin:CreateCommands()
   --only used for temp storage of a command
   local Command = nil
   
   
   local function PGP_Help( Client )
      --if the console ran the command
      if not Client then
         for i = 1, #HelpTable do
            Shared.Message(HelpTable[i])
         end
         
      else
         for i = 1, #HelpTable do
            ServerAdminPrint(Client, HelpTable[i])
         end
      end
   end
   
   Command = self:BindCommand( "pgp_help", nil, PGP_Help, true )
   Command:Help( "Prints the overview of PGP mod." ) 
   
   
   
   local function PGP_PrintConfig( Client )
      --if the console ran the command
      if not Client then
         for key,value in pairs(self.Config) do
            Shared.Message(string.format("%s = %s", key, value))
         end

      else
         for key,value in pairs(self.Config) do
            ServerAdminPrint(Client, string.format("%s = %s", key, value))
         end
         
      end
   end
   
   Command = self:BindCommand( "pgp_config", nil, PGP_PrintConfig, true)
   Command:Help( "Prints the current values of PGP's config file." ) 
   
   
   
   local function PGP_CheckLimit( Client, Boolean)
      if self.Config.CheckLimit == Boolean then
         local ErrorMsg = "CheckLimit is already %s."
         NotifyR(Client, "[PGP mod]", ErrorMsg, true, Boolean)
         
      else
         self.Config.CheckLimit = Boolean
         Plugin:SaveConfig()
         
         --reset the timers and state switching
         Plugin.PlyrLimEndTime = nil
         Plugin.PlyrLimEnableTime = nil
         
         local msg = "CheckLimit is now %s"
         NotifyG(Client, "[PGP mod]", msg, true, Boolean)
         
      end
      

   end
   
   Command = self:BindCommand("pgp_checklimit", "pgpcheck", PGP_CheckLimit)
   Command:AddParam{ Type = "boolean" }
   Command:Help( "<true/false> Should PGP turn on/off by player limit?")

   
   
   local function PGP_PlayerLimit( Client, Number)
      if self.Config.PlayerLimit == Number then
         local ErrorMsg = "PlayerLimit is already %d."
         NotifyR(Client, "[PGP mod]", ErrorMsg, true, Number)
         
      else
         local msg = "PlayerLimit changed from %d to %d."
         NotifyG( Client, "[PGP mod]", msg, true, 
                  self.Config.PlayerLimit, Number )
      
         self.Config.PlayerLimit = Number
         Plugin:SaveConfig()
         
         --reset the timers and state switching
         Plugin.PlyrLimEndTime = nil
         Plugin.PlyrLimEnableTime = nil
      end
      

   end
   
   Command = self:BindCommand("pgp_playerlimit", "pgplimit", PGP_PlayerLimit)
   Command:AddParam{ Type = "number" }
   Command:Help( "<#ofplayers> Sets the player limit PGP turns on/off")
   
   
   
   local function PGP_Disable( Client)
      if self.Config.EnablePGP == false then
         NotifyR(Client, "[PGP mod]", "PGP is already disabled.")
         
      else
         self.Config.EnablePGP = false
         Plugin:SaveConfig()
         
         if not Plugin.dt.PGP_On then 
            NotifyR(Client, "[PGP mod]", "PGP disabled.")
            return 
         end
         
         local Gamerules = GetGamerules()
         if Gamerules then Gamerules:ResetGame() end
         NotifyR(nil, "[PGP mod]", "PGP disabled.")
      end
   end
   
   Command = self:BindCommand("pgp_disable", "pgpdisable", PGP_Disable)
   Command:Help( "Prevent PGP from turning on. Will reset game if PGP is on")

   
   
   local function PGP_Enable( Client)
      if self.Config.EnablePGP == true then
         NotifyR(Client, "[PGP mod]", "PGP is already enabled.")
         
      else
         self.Config.EnablePGP = true
         Plugin:SaveConfig()
         
         local Gamerules = GetGamerules()
         
         if AtPlayerLimit(Gamerules) and Plugin.Config.CheckLimit then
            NotifyG(Client, "[PGP mod]", "PGP enabled.")
            return 
         end
         
         if Gamerules:GetGameState() ~= kGameState.NotStarted then 
            NotifyG(Client, "[PGP mod]", "PGP enabled.")
            return 
         end
         
         NotifyG(nil, "[PGP mod]", "PGP enabled.")
         if Gamerules then Gamerules:ResetGame() end

      end
   end
   
   Command = self:BindCommand("pgp_enable", "pgpenable", PGP_Enable)
   Command:Help( "Allow PGP to turn on. If under limit, will restart game.")

   
   
end


-- ============================================================================
-- ============================================================================















function Plugin:Initialise()
   self:CreateCommands()
   self.Enabled = true
   local rules = GetGamerules()
   if rules then rules:ResetGame() end
   return true
end



function Plugin:Cleanup()
   self.BaseClass.Cleanup( self )
   self.Enabled = false
   local rules = GetGamerules()
   if rules then rules:ResetGame() end
end


