
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIUnitStatus.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the blips that are displayed on the HUD, indicating status of nearby units.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Badges_Shared.lua")

class 'GUIUnitStatus' (GUIAnimatedScript)

GUIUnitStatus.kFontName = "fonts/AgencyFB_small.fnt"
GUIUnitStatus.kActionFontName = "fonts/AgencyFB_smaller_bordered.fnt"
GUIUnitStatus.kUnitStatusSize = Vector(60, 60, 0)

GUIUnitStatus.kAlphaPerSecond = 0.8
GUIUnitStatus.kImpulseIntervall = 2.5

local kBadgeSize = Vector(26, 26, 0)

GUIUnitStatus.kBlackTexture = "ui/black_dot.dds"

local kStatusBgTexture = { [kMarineTeamType] = "ui/unitstatus_marine.dds", [kAlienTeamType] = "ui/unitstatus_alien.dds", [kNeutralTeamType] = "ui/unitstatus_neutral.dds" }
local kStatusFontColor = { [kMarineTeamType] = Color(kMarineTeamColorFloat), [kAlienTeamType] = Color(kAlienTeamColorFloat), [kNeutralTeamType] = Color(1,1,1,1) }

GUIUnitStatus.kStatusBgSize = GUIScale( Vector(168, 70, 0) )
GUIUnitStatus.kStatusBgNoHintSize = GUIScale( Vector(168, 56, 0) )

GUIUnitStatus.kStatusBgOffset= GUIScale( Vector(0, -16, 0) )
GUIUnitStatus.kStatusBackgroundPixelCoords = { 256, 896 , 256 + 178, 896 + 53}

GUIUnitStatus.kUnpoweredColor = Color(1,0.2,0.2,1)
GUIUnitStatus.kEnemyColor = Color(1,0.3,0.3,1)

GUIUnitStatus.kFontScale = GUIScale( Vector(1,1,1) ) * 1.2
GUIUnitStatus.kActionFontScale = GUIScale( Vector(1,1,1) )
GUIUnitStatus.kFontScaleProgress = GUIScale( Vector(1,1,1) ) * 0.8
GUIUnitStatus.kFontScaleSmall = GUIScale( Vector(1,1,1) ) * 0.9

GUIUnitStatus.kUnitStatusBarWidth = GUIScale(512) * 0.4
GUIUnitStatus.kUnitStatusBarHeight = GUIScale(48) * 0.4
GUIUnitStatus.kUnitStatusBarTexCoords = { 256, 0, 256 + 512, 64 }
GUIUnitStatus.kBarYOffset = GUIScale(-40)

GUIUnitStatus.kProgressFontSize = GUIScale(20)

GUIUnitStatus.kProgressingIconSize = GUIScale(Vector(128, 128, 0))
GUIUnitStatus.kProgressingIconCoords = { 256, 68, 256 + 128, 68 + 128 }
GUIUnitStatus.kProgressingIconOffset = GUIScale(Vector(0, 128, 0))

GUIUnitStatus.kRotationDuration = 8
GUIUnitStatus.kResearchRotationDuration = 2

local kWelderTexCoords = GetTextureCoordinatesForIcon(kTechId.Welder)
local kWelderTexture = "ui/buildmenu.dds"

local kWelderIconSize = GUIScale(Vector(48, 48, 0))
local kWelderIconPos = GUIScale(Vector(0, -24, 0))

local kBorderCoords = { 256, 256, 256 + 512, 256 + 128 }
local kBorderMaskPixelCoords = { 256, 384, 256 + 512, 384 + 512 }
local kBorderMaskCircleRadius = GUIScale(130)

local kHealthBarWidth = GUIScale(130)
local kHealthBarHeight = GUIScale(8)

local kArmorBarWidth = GUIScale(130)
local kArmorBarHeight = GUIScale(4)

local kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"
local kSmokeyBackgroundSize = GUIScale(Vector(256, 130, 0))

local kNameDefaultPos = GUIScale(Vector(0, 4, 0))
local kActionDefaultPos = GUIScale(Vector(0, -16, 0))

local function GetUnitStatusTextureCoordinates(unitStatus)

    local x1 = 0
    local x2 = 256
    
    local y1 = (unitStatus - 1) * 256
    local y2 = unitStatus * 256

    return x1, y1, x2, y2

end

local function GetColorForUnitState(unitStatus)

    local color = Color(1,1,1,1)

    if unitStatus == kUnitStatus.Unpowered then
        color = GUIUnitStatus.kUnpoweredColor
    //elseif unitStatus == kUnitStatus.Researching then
    //    color = Color(0, 204/255, 1, 1)
    elseif unitStatus == kUnitStatus.Damaged then
        color = Color(1, 227/255, 69/255, 0.75)
    end

    return color    

end

local function DestroyActiveBlips(self)

    for _, blip in ipairs(self.activeBlipList) do
        GUI.DestroyItem(blip.statusBg)
        blip.GraphicsItem:Destroy()
    end

    self.activeBlipList = { }
    
end

function GUIUnitStatus:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.activeBlipList = { }
    
    self.useMarineStyle = false
    self.fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    
end

function GUIUnitStatus:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    DestroyActiveBlips(self)
    
end

function GUIUnitStatus:EnableMarineStyle()
    self.useMarineStyle = true
end

function GUIUnitStatus:EnableAlienStyle()
    self.useMarineStyle = false
end

local function Pulsate(script, item)

    item:SetColor(Color(1, 1, 1, 0.5), 0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear,
        function(script, item)
            item:SetColor(Color(1, 1, 1, 1), 0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear, Pulsate)
        end)
    
end

local function GetPixelCoordsForFraction(fraction)

    local width = GUIUnitStatus.kUnitStatusBarTexCoords[3] - GUIUnitStatus.kUnitStatusBarTexCoords[1]
    local x1 = GUIUnitStatus.kUnitStatusBarTexCoords[1]
    local x2 = x1 + width * fraction
    local y1 = GUIUnitStatus.kUnitStatusBarTexCoords[2]
    local y2 = GUIUnitStatus.kUnitStatusBarTexCoords[4]
    
    return x1, y1, x2, y2
    
end

local function CreateBlipItem(self)

    local newBlip = { }
    local teamType = PlayerUI_GetTeamType()
    local neutralTexture = "ui/unitstatus_neutral.dds"
    
    newBlip.ScreenX = 0
    newBlip.ScreenY = 0
    
    local texture = kStatusBgTexture[teamType]
    local fontColor = kStatusFontColor[teamType]

    newBlip.GraphicsItem = self:CreateAnimatedGraphicItem()
    newBlip.GraphicsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    if self.useMarineStyle then
        newBlip.GraphicsItem:SetBlendTechnique(GUIItem.Add)
    end
    newBlip.GraphicsItem:SetSize(GUIUnitStatus.kUnitStatusSize)
    newBlip.GraphicsItem:SetIsScaling(false)
    newBlip.GraphicsItem:SetColor(Color(1,1,1,0.4))
    newBlip.GraphicsItem:SetTexture(texture)
    newBlip.GraphicsItem:SetLayer(kGUILayerPlayerNameTags)
    
    newBlip.OverLayGraphic = self:CreateAnimatedGraphicItem()
    newBlip.OverLayGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    newBlip.OverLayGraphic:SetBlendTechnique(GUIItem.Add)
    newBlip.OverLayGraphic:SetSize(GUIUnitStatus.kUnitStatusSize)
    newBlip.OverLayGraphic:SetIsScaling(false)
    newBlip.OverLayGraphic:SetColor(Color(1,1,1,0.4))
    newBlip.OverLayGraphic:SetTexture(texture)
    newBlip.OverLayGraphic:SetLayer(kGUILayerPlayerNameTags)

    newBlip.ProgressingIcon = GetGUIManager():CreateGraphicItem()
    newBlip.ProgressingIcon:SetTexture(texture)
    newBlip.ProgressingIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.ProgressingIcon:SetBlendTechnique(GUIItem.Add) 
    newBlip.ProgressingIcon:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kProgressingIconCoords))
    newBlip.ProgressingIcon:SetSize(GUIUnitStatus.kProgressingIconSize)
    newBlip.ProgressingIcon:SetPosition(-GUIUnitStatus.kProgressingIconSize/2 + GUIUnitStatus.kProgressingIconOffset )
    newBlip.ProgressingIcon:SetIsVisible(false)
    
    newBlip.ProgressBackground = GetGUIManager():CreateGraphicItem()
    newBlip.ProgressBackground:SetTexture(GUIUnitStatus.kBlackTexture)
    newBlip.ProgressBackground:SetSize(GUIUnitStatus.kProgressingIconSize)
    newBlip.ProgressingIcon:AddChild(newBlip.ProgressBackground)
    
    newBlip.ProgressText = GetGUIManager():CreateTextItem()
    newBlip.ProgressText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    newBlip.ProgressText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.ProgressText:SetTextAlignmentY(GUIItem.Align_Center)
    newBlip.ProgressText:SetFontSize(GUIUnitStatus.kProgressFontSize)
    newBlip.ProgressText:SetColor(fontColor)
    newBlip.ProgressText:SetFontIsBold(true)
    newBlip.ProgressingIcon:AddChild(newBlip.ProgressText)
    
    newBlip.statusBg = GetGUIManager():CreateGraphicItem()
    
    newBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgSize)
    newBlip.statusBg:SetPosition(-GUIUnitStatus.kStatusBgSize * .5 + GUIUnitStatus.kStatusBgOffset )
    newBlip.statusBg:SetClearsStencilBuffer(true)
    
    if self.fullHUD and teamType == kAlienTeamType then
    
        newBlip.smokeyBackground = GetGUIManager():CreateGraphicItem()
        newBlip.smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
        newBlip.smokeyBackground:SetSize(kSmokeyBackgroundSize)
        newBlip.smokeyBackground:SetPosition(-kSmokeyBackgroundSize * .5)
        newBlip.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
        newBlip.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
        newBlip.smokeyBackground:SetFloatParameter("correctionX", 0.6)
        newBlip.smokeyBackground:SetFloatParameter("correctionY", 0.3)
        newBlip.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
        newBlip.smokeyBackground:SetColor(Color(1,1,1,0.6))
        newBlip.smokeyBackground:SetInheritsParentAlpha(true)
    
    end
    
    newBlip.HealthBarBg = GetGUIManager():CreateGraphicItem()
    newBlip.HealthBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.HealthBarBg:SetSize(Vector(kHealthBarWidth, kHealthBarHeight, 0))
    newBlip.HealthBarBg:SetPosition(Vector(-kHealthBarWidth / 2, -kHealthBarHeight - kArmorBarHeight - 4, 0))
    newBlip.HealthBarBg:SetTexture(neutralTexture)
    newBlip.HealthBarBg:SetColor(Color(0,0,0,0))
    newBlip.HealthBarBg:SetInheritsParentAlpha(true)
    newBlip.HealthBarBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    
    newBlip.HealthBar = GetGUIManager():CreateGraphicItem()
    newBlip.HealthBar:SetColor(kHealthBarColors[teamType])
    newBlip.HealthBar:SetSize(Vector(kHealthBarWidth, kHealthBarHeight, 0))
    newBlip.HealthBar:SetTexture(neutralTexture)
    newBlip.HealthBar:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    newBlip.HealthBar:SetBlendTechnique(GUIItem.Add)
    newBlip.HealthBar:SetInheritsParentAlpha(true)
    newBlip.HealthBarBg:AddChild(newBlip.HealthBar)
    
    newBlip.ArmorBarBg = GetGUIManager():CreateGraphicItem()
    newBlip.ArmorBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.ArmorBarBg:SetSize(Vector(kArmorBarWidth, kArmorBarHeight, 0))
    newBlip.ArmorBarBg:SetPosition(Vector(-kArmorBarWidth / 2, -kArmorBarHeight - 4, 0))
    newBlip.ArmorBarBg:SetTexture(neutralTexture)
    newBlip.ArmorBarBg:SetColor(Color(0,0,0,0))
    newBlip.ArmorBarBg:SetInheritsParentAlpha(true)
    newBlip.ArmorBarBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    
    newBlip.ArmorBar = GUIManager:CreateGraphicItem()
    newBlip.ArmorBar:SetColor(kArmorBarColors[teamType])
    newBlip.ArmorBar:SetSize(Vector(kArmorBarWidth, kArmorBarHeight, 0))
    newBlip.ArmorBar:SetTexture(neutralTexture)
    newBlip.ArmorBar:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    newBlip.ArmorBar:SetBlendTechnique(GUIItem.Add)
    newBlip.ArmorBar:SetInheritsParentAlpha(true)
    newBlip.ArmorBarBg:AddChild(newBlip.ArmorBar)
    
    newBlip.NameText = GUIManager:CreateTextItem()
    newBlip.NameText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.NameText:SetFontName(GUIUnitStatus.kFontName)
    newBlip.NameText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.NameText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.NameText:SetScale(GUIUnitStatus.kFontScale)
    newBlip.NameText:SetPosition(kNameDefaultPos)  
    
    newBlip.ActionText = GUIManager:CreateTextItem()
    newBlip.ActionText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.ActionText:SetFontName(GUIUnitStatus.kActionFontName)
    newBlip.ActionText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.ActionText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.ActionText:SetScale(GUIUnitStatus.kActionFontScale)
    newBlip.ActionText:SetPosition(kActionDefaultPos)  
    
    newBlip.HintText = GUIManager:CreateTextItem()
    newBlip.HintText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.HintText:SetFontName(GUIUnitStatus.kFontName)
    newBlip.HintText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.HintText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.HintText:SetScale(GUIUnitStatus.kFontScaleSmall)
    newBlip.HintText:SetPosition(GUIScale(Vector(0, 28, 0)))
    
    if self.fullHUD then
    
        newBlip.Border = GUIManager:CreateGraphicItem()
        newBlip.Border:SetAnchor(GUIItem.Left, GUIItem.Top)
        newBlip.Border:SetSize(GUIUnitStatus.kStatusBgSize)
        newBlip.Border:SetTexture(neutralTexture)
        newBlip.Border:SetTexturePixelCoordinates(unpack(kBorderCoords))
        newBlip.Border:SetIsStencil(true)
        
        newBlip.BorderMask = GUIManager:CreateGraphicItem()
        newBlip.BorderMask:SetTexture(neutralTexture)
        newBlip.BorderMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
        newBlip.BorderMask:SetBlendTechnique(GUIItem.Add)
        newBlip.BorderMask:SetTexturePixelCoordinates(unpack(kBorderMaskPixelCoords))
        newBlip.BorderMask:SetSize(Vector(kBorderMaskCircleRadius * 2, kBorderMaskCircleRadius * 2, 0))
        newBlip.BorderMask:SetPosition(Vector(-kBorderMaskCircleRadius, -kBorderMaskCircleRadius, 0))
        newBlip.BorderMask:SetStencilFunc(GUIItem.NotEqual)
        newBlip.Border:AddChild(newBlip.BorderMask)
    
    end
    
    // Create badge icon items
    newBlip.Badges = {}
    for i = 1,Badges_GetMaxBadges() do

        local badge = GUIManager:CreateGraphicItem()
        badge:SetAnchor(GUIItem.Left, GUIItem.Top)
        badge:SetSize(kBadgeSize)
        badge:SetPosition(Vector(-i * (kBadgeSize.x+5), kNameDefaultPos.y, 0))
        badge:SetIsVisible(false)
        badge:SetInheritsParentAlpha(true)

        table.insert( newBlip.Badges, badge )
        newBlip.statusBg:AddChild(badge)

    end
    
    if newBlip.smokeyBackground then
        newBlip.statusBg:AddChild(newBlip.smokeyBackground)
    end
    
    newBlip.statusBg:AddChild(newBlip.HealthBarBg)
    newBlip.statusBg:AddChild(newBlip.ArmorBarBg)
    newBlip.statusBg:AddChild(newBlip.NameText)
    newBlip.statusBg:AddChild(newBlip.HintText)
    
    if self.fullHUD then
        newBlip.statusBg:AddChild(newBlip.Border)
    end
    
    newBlip.statusBg:SetColor(Color(0,0,0,0))
    
    newBlip.GraphicsItem:AddChild(newBlip.ProgressingIcon)
    newBlip.GraphicsItem:AddChild(newBlip.OverLayGraphic)
    
    newBlip.ProgressingIcon:AddChild(newBlip.ActionText)
    
    return newBlip
    
end

local function AddWelderIcon(blipItem)

    blipItem.welderIcon = GetGUIManager():CreateGraphicItem()
    blipItem.welderIcon:SetTexture(kWelderTexture)
    blipItem.welderIcon:SetTexturePixelCoordinates(unpack(kWelderTexCoords))
    blipItem.welderIcon:SetSize(kWelderIconSize)
    blipItem.welderIcon:SetPosition(kWelderIconPos)
    blipItem.welderIcon:SetAnchor(GUIItem.Right, GUIItem.Center)    
    
    blipItem.statusBg:AddChild(blipItem.welderIcon)

end

local function UpdateUnitStatusList(self, activeBlips, deltaTime)

    PROFILE("GUIUnitStatus:UpdateUnitStatusList")
    
    local numBlips = #activeBlips
    
    while numBlips > table.count(self.activeBlipList) do
    
        local newBlipItem = CreateBlipItem(self)
        table.insert(self.activeBlipList, newBlipItem)
        newBlipItem.GraphicsItem:DestroyAnimations()
        newBlipItem.GraphicsItem:FadeIn(0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear, Pulsate)
        
    end
    
    while numBlips < table.count(self.activeBlipList) do
    
        // fade out and destroy
        self.activeBlipList[1].GraphicsItem:Destroy()
        GUI.DestroyItem(self.activeBlipList[1].statusBg)
        table.remove(self.activeBlipList, 1)
        
    end
    
    local baseResearchRot = (Shared.GetTime() % GUIUnitStatus.kResearchRotationDuration) / GUIUnitStatus.kResearchRotationDuration
    local showHints = Client.GetOptionBoolean("showHints", true) == true
    
    // Update current blip state.
    local currentIndex = 1
    for i = 1, #self.activeBlipList do
    
        local blipData = activeBlips[i]
        local updateBlip = self.activeBlipList[i]
        
        local playerTeamType = PlayerUI_GetTeamType()
        local teamType = blipData.TeamType
        local isEnemy = false
        
        if playerTeamType ~= kNeutralTeamType then
        
            isEnemy = (playerTeamType ~= blipData.TeamType) and (teamType ~= kNeutralTeamType)
            teamType = playerTeamType
            
        end
        
        // status icon, color and unit name
        updateBlip.GraphicsItem:SetTexturePixelCoordinates(GetUnitStatusTextureCoordinates(blipData.Status))
        updateBlip.GraphicsItem:SetPosition(blipData.Position - GUIUnitStatus.kUnitStatusSize * .5 )
        
        updateBlip.OverLayGraphic:SetTexturePixelCoordinates(GetUnitStatusTextureCoordinates(blipData.Status))
        
        local statusTexture = kStatusBgTexture[teamType]
        
        if not self.fullHUD then
            statusTexture = kTransparentTexture
        end
        
        updateBlip.statusBg:SetTexture(statusTexture)
        updateBlip.statusBg:SetPosition(blipData.HealthBarPosition - GUIUnitStatus.kStatusBgSize * .5 )

        if blipData.HealthFraction == 0 or PlayerUI_IsACommander() or CHUDSettings["mingui"] then
            updateBlip.statusBg:SetTexturePixelCoordinates(0, 0, 0, 0)
        else        
            updateBlip.statusBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kStatusBackgroundPixelCoords))
        end 
        
        // status description
        local showDetail = blipData.StatusFraction ~= 0 and blipData.StatusFraction ~= 1
        updateBlip.ProgressingIcon:SetIsVisible(blipData.IsCrossHairTarget and showDetail)
        updateBlip.ProgressText:SetText(math.floor(blipData.StatusFraction * 100) .. "%")
        
        local healthBarBgColor = Color(kHealthBarColors[teamType])
        healthBarBgColor.r = healthBarBgColor.r * .5
        healthBarBgColor.g = healthBarBgColor.g * .5
        healthBarBgColor.b = healthBarBgColor.b * .5
        
        local armorBarBgColor = Color(kArmorBarColors[teamType])
        armorBarBgColor.r = armorBarBgColor.r * .5
        armorBarBgColor.g = armorBarBgColor.g * .5
        armorBarBgColor.b = armorBarBgColor.b * .5
        
        updateBlip.HealthBar:SetColor(kHealthBarColors[teamType])
        updateBlip.ArmorBar:SetColor(kArmorBarColors[teamType])
        updateBlip.HealthBarBg:SetColor(healthBarBgColor)
        updateBlip.HealthBarBg:SetIsVisible(blipData.HealthFraction ~= 0)
        updateBlip.ArmorBarBg:SetColor(armorBarBgColor)
        updateBlip.ArmorBarBg:SetIsVisible(blipData.ArmorFraction ~= 0)
        
        local alpha = 0
        
        if blipData.IsCrossHairTarget then        
            alpha = 1
        else
            alpha = 0
        end
        
        // use the entities team color here, so you can make a difference between enemy or friend
        updateBlip.statusBg:SetColor(Color(1,1,1,alpha))
        updateBlip.NameText:SetText(blipData.Name)
        updateBlip.NameText:SetIsVisible(self.fullHUD or blipData.IsPlayer or CHUDSettings["minnps"])
        updateBlip.ActionText:SetText(blipData.Action)
        
        local hintVisible = showHints and blipData.Hint ~= nil and string.len(blipData.Hint) > 0
        
        if hintVisible then
            updateBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgSize)
            
            if updateBlip.Border then            
                updateBlip.Border:SetSize(GUIUnitStatus.kStatusBgSize)
            end
            
        else    
            updateBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgNoHintSize)
            
            if updateBlip.Border then            
                updateBlip.Border:SetSize(GUIUnitStatus.kStatusBgNoHintSize)
            end
            
        end    
		
		if CHUDSettings["mingui"] and self.fullHUD then
			updateBlip.Border:SetSize(Vector(0,0,0))
		end
        
        // Only show hint text with hints enabled
        if updateBlip.HintText and showHints then
            updateBlip.HintText:SetText(blipData.Hint)
        end
		
		// MOD START
		if CHUDSettings["minnps"] then
			updateBlip.HintText:SetText(blipData.Hint)
		end
		// MOD END
        
        local textColor = Color(kNameTagFontColors[teamType])
        
        if isEnemy then
            textColor = GUIUnitStatus.kEnemyColor
        end
        
        if not blipData.ForceName then
            textColor.a = alpha
        end
        updateBlip.NameText:SetColor(textColor)
        updateBlip.ActionText:SetColor(textColor)
        if updateBlip.HintText then
            updateBlip.HintText:SetColor(textColor)
        end
        
        updateBlip.HealthBar:SetSize(Vector(kHealthBarWidth * blipData.HealthFraction, kHealthBarHeight, 0))
        updateBlip.HealthBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(blipData.HealthFraction))
        
        updateBlip.ArmorBar:SetSize(Vector(kArmorBarWidth * blipData.ArmorFraction, kArmorBarHeight, 0))
        updateBlip.ArmorBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(blipData.ArmorFraction)) 
        
        updateBlip.ProgressingIcon:SetRotation(Vector(0, 0, -2 * math.pi * baseResearchRot))
        
        if updateBlip.BorderMask then
        
            updateBlip.BorderMask:SetRotation(Vector(0, 0, -2 * math.pi * baseResearchRot))
            updateBlip.BorderMask:SetIsVisible(teamType == kMarineTeamType and blipData.IsCrossHairTarget)
            
        end
        
        if updateBlip.smokeyBackground then
            updateBlip.smokeyBackground:SetIsVisible(blipData.HealthFraction ~= 0 and not CHUDSettings["mingui"])
        end

        assert( #updateBlip.Badges >= #blipData.BadgeTextures )
        for i = 1, #updateBlip.Badges do

            local badge = updateBlip.Badges[i]
            local texture = blipData.BadgeTextures[i]

            if texture ~= nil then

                badge:SetTexture(texture)
                badge:SetIsVisible(true)

            else
                badge:SetIsVisible(false)
            end

        end
        
        if blipData.HasWelder and blipData.IsCrossHairTarget and not updateBlip.welderIcon then
        
            AddWelderIcon(updateBlip)
        
        elseif (not blipData.HasWelder or not blipData.IsCrossHairTarget) and updateBlip.welderIcon then
        
            GUI.DestroyItem(updateBlip.welderIcon)
            updateBlip.welderIcon = nil
            
        end
         
    end

end

function GUIUnitStatus:Update(deltaTime)

    PROFILE("GUIUnitStatus:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    if self.fullHUD ~= fullHUD and not CHUDSettings["mingui"] then
        
        self.fullHUD = fullHUD
        DestroyActiveBlips(self)
        
    end
    
    UpdateUnitStatusList(self, PlayerUI_GetUnitStatusInfo(), deltaTime)
    
end
