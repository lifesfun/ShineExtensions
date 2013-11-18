
local Plugin = {}

function Plugin:SetupDataTable()
	self:AddDTVar( "integer", "ConcedeTime", kMinTimeBeforeConcede )
end

Shine:RegisterExtension( "votesurrender", Plugin )

if Server then return end

function Plugin:NetworkUpdate( Key, Old, New )
	if Key == "ConcedeTime" then
		kMinTimeBeforeConcede = New or kMinTimeBeforeConcede
	end
end
