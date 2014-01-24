-- ==============================================================
--
-- Lerk Lift Mod v0.1
--    by Hackepeter
--
-- Date: 2011-10-28
--
-- Installation: place this file in ns2\lua and add to the beginning
-- of Alien_Server.lua: Script.Load("lua/LerkLiftMod.lua")
-- 
-- Admins can turn the mod at anytime (also mid game) off/on
-- with lerklift 0/1 in the server console.
--
-- ==============================================================

-- should the mod be enabled by default?
Alien.kLiftEnabled = true

Alien.kLiftInterval = 1

Alien.kLifterClass = "Lerk"
Alien.kLiftedClass = "Gorge"

Alien.kLifterTip = "You just lifted a Gorge. Press use-key to release."
Alien.kLiftedTip = "You just lifted by a Lerk. Press use-key to release."

Alien.kLifterOnSound = "alien_vision_on"
Alien.kLifterOffSound = "alien_vision_off"

function Alien:GetCanBeUsed()

    if self:GetIsAlive() then
        return true
    end
	
    return Player.GetCanBeUsed(self)
end

function Alien:OnUse(player, elapsedTime, useAttachPoint, usePoint)

	if Alien.kLiftEnabled and -- don't trigger lifting to often
	(self.timeOfLastLift == nil or (Shared.GetTime() - self.timeOfLastLift) > Alien.kLiftInterval) then
		-- if this is the Gorge used by a Lerk
		if self:isa(Alien.kLiftedClass) and player:isa(Alien.kLifterClass) then
		
			-- if the Lerk is not yet lifting any Gorge
			if player.liftingToId == nil then
			
				-- lift the gorge
				self:SetLiftingTo(player)
				self.timeOfLastLift = Shared.GetTime()
				
				return true
			-- if the Lerk is already lifting this Gorge (me)
			elseif player.liftingToId == self:GetId() then
			
				-- release
				self:ResetLifting()
				self.timeOfLastLift = Shared.GetTime()
				
				return true
			end
		
		-- if this is the Lerk used by a Gorge
		elseif self:isa(Alien.kLifterClass) and player:isa(Alien.kLiftedClass) then
		
			-- if the Lerk is already lifting this Gorge
			if self.liftingToId == player:GetId() then
			
				-- release
				self:ResetLifting()
				self.timeOfLastLift = Shared.GetTime()
				
				return true
			end
		end
	end
	
	return Player.OnUse(self, player, elapsedTime, useAttachPoint, usePoint)
end

function Alien:PostUpdateMove(input, runningPrediction)

	-- only do stuff if something is lifted
	if self.liftingToId ~= nil then
		if Alien.kLiftEnabled then
		
			local isLifter = self:isa(Alien.kLifterClass)
			local isLifted = self:isa(Alien.kLiftedClass)
			if isLifter or isLifted then
			
				local liftingTo = nil
				if self.liftingToId ~= nil then
					liftingTo = Shared.GetEntity(self.liftingToId)
				
					-- check if there is a lifting
					if liftingTo ~= nil and liftingTo:GetIsAlive() then
					
						-- if this alien is lifted copy position from lifter
						if isLifted then
							lifterPos = liftingTo:GetOrigin();
							local liftedPos = Vector(lifterPos.x, lifterPos.y, lifterPos.z)
							self:SetOrigin(liftedPos)
						end
					else
						-- reset if lifted alien is dead or vanished
						self:ResetLifting()
					end
					
				end
			end
		-- if lifting has been disabled in midgame reset this lifting now
		else
			self:ResetLifting()
		end
	end
end

-- enabled the lifting between two aliens if there is no other lifting
function Alien:SetLiftingTo(otherAlien)

	if self.liftingToId  == nil then
		self.liftingToId = otherAlien:GetId()
		self:TriggerEffects(Alien.kLifterOnSound)
		self:AddTooltip(ConditionalValue(self:isa(Alien.kLiftedClass), Alien.kLiftedTip, Alien.kLifterTip))
		otherAlien:SetLiftingTo(self)
	end
end

-- reset all linking between lifter and lifted alien
function Alien:ResetLifting()

	if self.liftingToId ~= nil then
	
		local liftingTo = Shared.GetEntity(self.liftingToId)
		self.liftingToId = nil
		if liftingTo ~= nil then
			liftingTo:ResetLifting()
		end
		
		self:TriggerEffects(Alien.kLifterOffSound)

	end
	
end

