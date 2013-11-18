--[[
	Shine fun commands plugin.
]]

local Plugin = {}
Plugin.Version = "1.0"

function Plugin:Initialise()
	self:CreateCommands()

	self.Enabled = true

	return true
end

function Plugin:MovePlayerToPlayer( Player, TargetPlayer )
	local Pos = TargetPlayer:GetOrigin()
	local TechID = kTechId.Skulk

	if Player:GetIsAlive() then
		TechID = Player:GetTechId()
	end

	local Bounds = LookupTechData( TechID, kTechDataMaxExtents )

	if not Bounds then return false end

	local Height, Radius = GetTraceCapsuleFromExtents( Bounds )

	local SpawnPoint
	local Range = 6
	local i = 1

	repeat
		SpawnPoint = GetRandomSpawnForCapsule( Height, Radius, Pos, 2, Range, EntityFilterAll() )
		i = i + 1
	until SpawnPoint or i > 10

	if SpawnPoint then
		SpawnPlayerAtPoint( Player, SpawnPoint )

		return true
	end

	return false
end

function Plugin:CreateCommands()
	local function Slay( Client, Targets )
		for i = 1, #Targets do
			local Player = Targets[ i ]:GetControllingPlayer()
			if Player then
				Player:Kill( nil, nil, Player:GetOrigin() )
			end
		end
	end
	local SlayCommand = self:BindCommand( "sh_slay", "slay", Slay )
	SlayCommand:AddParam{ Type = "clients" }
	SlayCommand:Help( "<players> Slays the given player(s)." )

	local function GoTo( Client, Target )
		if not Client then return end
		
		local TargetPlayer = Target:GetControllingPlayer()
		local Player = Client:GetControllingPlayer()

		if not Player or not TargetPlayer then return end
		
		if not self:MovePlayerToPlayer( Player, TargetPlayer ) then
			Shine:NotifyError( Client, "Failed to find valid location near player." )
		else
			Shine:CommandNotify( Client, "teleported to %s.", true, TargetPlayer:GetName() or "<unknown>" )
		end
	end
	local GoToCommand = self:BindCommand( "sh_goto", "goto", GoTo )
	GoToCommand:AddParam{ Type = "client", NotSelf = true, IgnoreCanTarget = true }
	GoToCommand:Help( "<player> Moves you to the given player." )

	local function Bring( Client, Target )
		if not Client then return end

		local TargetPlayer = Target:GetControllingPlayer()
		local Player = Client:GetControllingPlayer()

		if not Player or not TargetPlayer then return end
		
		if not self:MovePlayerToPlayer( TargetPlayer, Player ) then
			Shine:NotifyError( Client, "Failed to find valid location near you." )
		else
			Shine:CommandNotify( Client, "teleported %s to themself.", true, TargetPlayer:GetName() or "<unknown>" )
		end
	end
	local BringCommand = self:BindCommand( "sh_bring", "bring", Bring )
	BringCommand:AddParam{ Type = "client", NotSelf = true }
	BringCommand:Help( "<player> Moves the given player to your location." )

	local function DarwinMode( Client, Targets, Enable )
		for i = 1, #Targets do
			local Player = Targets[ i ]:GetControllingPlayer()
			if Player then
				Player:SetDarwinMode( Enable )
			end
		end
	end
	local DarwinModeCommand = self:BindCommand( "sh_darwin", { "god", "darwin" }, DarwinMode )
	DarwinModeCommand:AddParam{ Type = "clients" }
	DarwinModeCommand:AddParam{ Type = "boolean" }
	DarwinModeCommand:Help( "<players> <true/false> Enables or disables Darwin mode on the given players (unlimited health and ammo)." )
end

Shine:RegisterExtension( "funcommands", Plugin )
