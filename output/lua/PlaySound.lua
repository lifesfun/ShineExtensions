if Server then
	local soundList = {
		"mess",
		"better",
		"dead",
		"dance",
		"dosomething",
		"ayumi",
		"nancy",
	}
	local userDecalList = { } 
	local userDecalPath = { }
	
	PrecacheAsset("sound/comtaunts.fev/taunts/mess")
	PrecacheAsset("sound/comtaunts.fev/taunts/nancy")
	PrecacheAsset("sound/comtaunts.fev/taunts/ayumi")
	PrecacheAsset("sound/comtaunts.fev/taunts/better")
	PrecacheAsset("sound/comtaunts.fev/taunts/dance")
	PrecacheAsset("sound/comtaunts.fev/taunts/dead")
	PrecacheAsset("sound/comtaunts.fev/taunts/dosomething")
	for i, sound in ipairs(soundList) do
		PrecacheAsset("sound/comtaunts.fev/taunts" .. sound)
	end
	
	    -- Parse the server admin file
	do
        local function LoadConfigFile(fileName)
            local openedFile = io.open("config://" .. fileName, "r")
            if openedFile then
            
                local parsedFile = openedFile:read("*all")
                io.close(openedFile)
                return parsedFile
                
            end
            return nil
        end
		
        local function ParseJSONStruct(struct)
            return json.decode(struct) or {}
        end
		local serverAdmin = ParseJSONStruct(LoadConfigFile("ServerAdmin.json"))
        if serverAdmin.users then
            for _, user in pairs(serverAdmin.users) do
				for i = 1, #user.groups do
					-- Check if the group has a decal assigned
					local groupName = user.groups[i]
					local group = serverAdmin.groups[groupName]
					if group then
						local sGroupDecals = group.decal or {}
						if group.decal then
							table.insert(userDecalList, user.id)
							table.insert(userDecalPath, group.decal)
						end
					end
				end    
            end
        end
    end
	
	local playerIndex = nil
	local commandTime = 0
	local paths = nil
	local function OnConsoleSound(client, name)
		local player = client:GetControllingPlayer()		
		local origin = player:GetOrigin()
	
		if client ~= nil and name ~= nil then
		
			if ToString(name) == "rave" or Shared.GetCheatsEnabled() then
				if not player:GetGameStarted() then
					StartSoundEffectAtOrigin("sound/comtaunts.fev/taunts/nancy", origin)
					local nearbyPlayers = GetEntitiesWithinRange("Player", origin, 20)
					
					for p = 1, #nearbyPlayers do		
						Server.SendNetworkMessage(nearbyPlayers[p], "RaveCinematic", { origin = origin }, true)
					end
					
					commandTime = Shared.GetTime()
				end
			elseif ToString(name) == "nancy" and player:GetGameStarted() == false and (Shared.GetTime() - commandTime > 3.5) or Shared.GetCheatsEnabled() then
				StartSoundEffectAtOrigin("sound/comtaunts.fev/taunts/nancy", origin)
				commandTime = Shared.GetTime()
			elseif ToString(name) == "ayumi" and player:GetGameStarted() == false and (Shared.GetTime() - commandTime > 3.5) or Shared.GetCheatsEnabled() then
				StartSoundEffectAtOrigin("sound/comtaunts.fev/taunts/ayumi", origin)
				commandTime = Shared.GetTime()
			elseif ToString(name) ~= "nancy" and ToString(name) ~= "ayumi" and ToString(name) ~= "dosomething" and ToString(name) ~= "rave" and (Shared.GetTime() - commandTime > 3.5) then
				StartSoundEffectAtOrigin("sound/comtaunts.fev/taunts/" .. ToString(name), origin)
				commandTime = Shared.GetTime()
			end
			
		end
	end
	CreateServerAdminCommand("Console_sound", OnConsoleSound, "<soundname> Plays the specified sound if it exists.")
	//Event.Hook("Console_sound", OnConsoleSound)

	local commandTimes = 0
	local function OnConsoleCreateSpray(client)
		local player = client:GetControllingPlayer()
		local origin = player:GetOrigin()
		
		for i, index in ipairs(userDecalList) do
			playerIndex = table.find(userDecalList, Server.GetOwner(player):GetUserId()) 
		end
		
		if client ~= nil and playerIndex ~= nil then
			
			if player:GetIsPlaying() == false and (Shared.GetTime() - commandTime > 3.5) or Shared.GetCheatsEnabled() then

				local startPoint = player:GetEyePos()
				local endPoint = startPoint + player:GetViewCoords().zAxis * 100
				local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
				
				if trace.fraction ~= 1 then
					local coords = Coords.GetTranslation(trace.endPoint)
					coords.origin = player:GetEyePos()
					coords.yAxis = trace.normal
					coords.zAxis = coords.yAxis:GetPerpendicular()
					coords.xAxis = coords.yAxis:CrossProduct(coords.zAxis)
					local angles = Angles()
					angles:BuildFromCoords(coords)
					for i, index in pairs(userDecalPath) do
						paths = index[playerIndex]
						Print("path " .. ToString(paths))
						Print("index " .. ToString(index))
					end
					local nearbyPlayers = GetEntitiesWithinRange("Player", origin, 20)
					for p = 1, #nearbyPlayers do
						Server.SendNetworkMessage(nearbyPlayers[p], "CreateSpray", { originX = coords.origin.x, originY = coords.origin.y, originZ = coords.origin.z, 
						yaw = angles.yaw, pitch = angles.pitch, roll = angles.roll, path = ToString(paths)}, true)
					end
					commandTimes = Shared.GetTime()
				end
			end	
		end
	end
CreateServerAdminCommand("Console_spray", OnConsoleCreateSpray, "Sprays a decal")
//Event.Hook("Console_spray", OnConsoleCreateSpray)

end

local rave =
{
    origin = "vector",
}
Shared.RegisterNetworkMessage("RaveCinematic", rave)

local spray =
{
	originX = "float",
	originY = "float",
	originZ = "float",
    yaw = "float",
    roll = "float",
	pitch = "float",
	path = "string (20)"
}
Shared.RegisterNetworkMessage("CreateSpray", spray)
local cinematic = nil
if Client then
	
	local soundList = {
		"mess", "better", "dead", "dance", "dosomething"
	}
	local function OnUpdateClient()

		local player = Client.GetLocalPlayer()
		local gameTime = PlayerUI_GetGameStartTime()
        
		if gameTime ~= 0 then
			gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
		end
		if player ~= nil and gameTime > 0 and cinematic ~= nil then
			Client.DestroyCinematic(cinematic)
			cinematic = nil
		end
	end
	
	Event.Hook("UpdateClient", OnUpdateClient)
	
	local function OnRave(message)
		local coords = Coords()
		coords.origin = message.origin
		if cinematic == nil then
			cinematic = Client.CreateCinematic(RenderScene.Zone_Default)
			cinematic:SetCinematic("cinematics/RAVE.cinematic")
			cinematic:SetCoords(coords)
			cinematic:SetIsVisible(true)
			cinematic:SetRepeatStyle(Cinematic.Repeat_Loop)
		else
			Client.DestroyCinematic(cinematic)
			cinematic = nil
		end
    end
    Client.HookNetworkMessage("RaveCinematic", OnRave)	
    
	local function OnSpray(message)
		local origin = Vector(message.originX, message.originY, message.originZ)
		local coords = Angles(message.pitch, message.yaw, message.roll):GetCoords(origin)
		if message.path == nil then
			Client.CreateTimeLimitedDecal(message.path, coords, 1.5)
		else
			Client.CreateTimeLimitedDecal("ui/gorge_.material", coords, 1.5)
		end
		
    end
    Client.HookNetworkMessage("CreateSpray", OnSpray)	
	
		
	local function OnConsoleSoundHelp()
		Shared.Message("Available commands before game starts")
		Shared.Message("ayumi")
		Shared.Message("nancy")
		Shared.Message("Available commands at any time")
		for i, sound in ipairs(soundList) do
			Shared.Message(sound)
		end
	end
	Event.Hook("Console_soundhelp", OnConsoleSoundHelp)
 
end