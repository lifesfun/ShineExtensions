Script.Load("lua/Class.lua")

MarineHUDOverride = false
AlienHUDOverride = false
UnitStatusOverride = false
WorldTextOverride = false

originalGUIScript = Class_ReplaceMethod( "GUIManager", "CreateGUIScript",
	function(self, scriptName)
		local script = originalGUIScript(self, scriptName)
		
		if (scriptName == "Hud/Marine/GUIMarineHUD") then
			if not MarineHUDOverride then
				MarineHUDOverride = true
				originalMarineHUDUpdate = Class_ReplaceMethod( "GUIMarineHUD", "Update",
					function(self, deltaTime)
						originalMarineHUDUpdate(self, deltaTime)
						self.resourceDisplay.teamText:SetIsVisible(CHUDSettings["minimap"] or (CHUDSettings["showcomm"] and not CHUDSettings["minimap"]))
						if not CHUDSettings["minimap"] and not CHUDSettings["showcomm"] then
							self.resourceDisplay.teamText:SetText("")
						end
						
						if CHUDSettings["mingui"] then
							self.inventoryDisplay:SetIsVisible(false)
						end
												
						if CHUDSettings["gametime"] and (CHUDSettings["showcomm"] or CHUDSettings["minimap"]) then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							local gameTimeText = string.format(" - %d:%02d", minutes, seconds)
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, seconds))
						end
						
						local s_rts
						
						if not CHUDSettings["rtcount"] then
							self.resourceDisplay.rtCount:SetIsVisible(false)
							if CommanderUI_GetTeamHarvesterCount() ~= 1 then
								s_rts = "RTs"
							else
								s_rts = "RT"
							end
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES") .. " (" .. ToString(CommanderUI_GetTeamHarvesterCount()) .. " " .. s_rts ..")")
						else
							self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
						end
				end)
			end
			Class_ReplaceMethod( "GUIMarineHUD", "OnLocalPlayerChanged",
				function(self, newPlayer)
					if CHUDSettings["mingui"] then
						self.topLeftFrame:SetIsVisible(false)
						self.topRightFrame:SetIsVisible(false)
						self.bottomLeftFrame:SetIsVisible(false)
						self.bottomRightFrame:SetIsVisible(false)
					end
				end
			)
			ApplyCHUDSettings()
				
		elseif (scriptName == "GUIAlienHUD") then
			if not AlienHUDOverride then
				AlienHUDOverride = true
				originalAlienHUDUpdate = Class_ReplaceMethod( "GUIAlienHUD", "Update",
					function(self, deltaTime)
						originalAlienHUDUpdate(self, deltaTime)
						
						local s_rts
						
						if not CHUDSettings["rtcount"] then
							self.resourceDisplay.rtCount:SetIsVisible(false)
							if CommanderUI_GetTeamHarvesterCount() ~= 1 then
								s_rts = "RTs"
							else
								s_rts = "RT"
							end
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES") .. " (" .. ToString(CommanderUI_GetTeamHarvesterCount()) .. " " .. s_rts ..")")
						else
							self.resourceDisplay.rtCount:SetIsVisible(CommanderUI_GetTeamHarvesterCount() > 0)
							self.resourceDisplay.pResDescription:SetText(Locale.ResolveString("RESOURCES"))
						end
						
						if CHUDSettings["gametime"] then
							local gameTime = PlayerUI_GetGameStartTime()
							
							if gameTime ~= 0 then
								gameTime = math.floor(Shared.GetTime()) - PlayerUI_GetGameStartTime()
							end
							
							local minutes = math.floor(gameTime / 60)
							local seconds = gameTime - minutes * 60
							local gameTimeText = string.format(" - %d:%02d", minutes, seconds)
							
							self.resourceDisplay.teamText:SetText(string.format(Locale.ResolveString("TEAM_RES") .. "\n%d:%02d", math.floor(PlayerUI_GetTeamResources()), minutes, seconds))
						end
						
						self.resourceDisplay.teamText:SetIsVisible(CHUDSettings["showcomm"] or CHUDSettings["minimap"])
				end)
			end
			ApplyCHUDSettings()
		
		elseif (scriptName == "GUIProgressBar") then
			script:Uninitialize()
			if CHUDSettings["mingui"] then
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 0, 0 }})
			else
				ReplaceLocals(GUIProgressBar.Initialize, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})
				ReplaceLocals(GUIProgressBar.InitCircleMask, {kBackgroundPixelCoords = { 0, 0, 230, 50 }})	
			end
			script:Initialize()
			if PlayerUI_GetTeamType() == kAlienTeamType then
				script.smokeyBackground:SetIsVisible(not CHUDSettings["mingui"])
			end
			
		elseif (scriptName == "GUIAlienBuyMenu") then
			if CHUDSettings["mingui"] then
				script.backgroundCircle:SetIsVisible(false)
				script.glowieParticles:Uninitialize()
				script.smokeParticles:Uninitialize()
				for cornerName, cornerItem in pairs(script.corners) do
					GUI.DestroyItem(cornerItem)
				end
				script.corners = { }
				
				script.cornerTweeners = { }
			end
			
		elseif (scriptName == "GUIGorgeBuildMenu") then
			script:Uninitialize()
			if CHUDSettings["mingui"] then
				script.kSmokeSmallTextureCoordinates = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = Vector(0, 0, 0)})
			else
				script.kSmokeSmallTextureCoordinates = { { 916, 4, 1020, 108 }, { 916, 15, 1020, 219 }, { 916, 227, 1020, 332 }, { 916, 332, 1020, 436 } }
				ReplaceLocals(GUIGorgeBuildMenu.CreateButton, {kSmokeyBackgroundSize = GUIScale(Vector(220, 400, 0))})
			end
			script:Initialize()
			
		elseif (scriptName == "GUIMarineBuyMenu") then
			if CHUDSettings["mingui"] then
				script.background:SetColor(Color(1, 1, 1, 0))
				script.repeatingBGTexture:SetTexturePixelCoordinates(0, 0, 0, 0)
				script.content:SetTexturePixelCoordinates(0, 0, 0, 0)
				script.scanLine:SetIsVisible(false)
				script.resourceDisplayBackground:SetTexturePixelCoordinates(0, 0, 0, 0)
			end
				
		elseif (scriptName == "GUIWorldText") and not WorldTextOverride then
			WorldTextOverride = true
			originalWorldTextUpdate = Class_ReplaceMethod( "GUIWorldText", "UpdateDamageMessage",
				function(self, message, messageItem, useColor, deltaTime)
					originalWorldTextUpdate(self, message, messageItem, useColor, deltaTime)
					local oldalpha = useColor.a
					if CHUDSettings["smalldmg"] then
						messageItem:SetScale(messageItem:GetScale()*0.5)
					end
					useColorCHUD = ConditionalValue(PlayerUI_IsOnMarineTeam(), ColorIntToColor(CHUDSettings["dmgcolor_m"]), ColorIntToColor(CHUDSettings["dmgcolor_a"]))
					messageItem:SetColor(Color(useColorCHUD.r, useColorCHUD.g, useColorCHUD.b, oldalpha))
				end)
				
		end
				
	return script
	end
)