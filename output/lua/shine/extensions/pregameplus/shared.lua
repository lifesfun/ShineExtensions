local Plugin = {}

Plugin.DefaultState = true

function Plugin:SetupDataTable()
   --flag that determines whether to run PGP functionalities
   self:AddDTVar( "boolean", "PGP_On", false )
end



--enables marines to use the buildings and macs during PGP
--exo using is enabled in server.lua since client can't reference it
function Armory:GetUseAllowedBeforeGameStart()
   if Plugin.dt.PGP_On then return true end
   return false
end

function PrototypeLab:GetUseAllowedBeforeGameStart()
   if Plugin.dt.PGP_On then return true end
   return false
end

function MAC:GetUseAllowedBeforeGameStart()
   if Plugin.dt.PGP_On then return true end
   return false
end




Shine:RegisterExtension( "pregameplus", Plugin)