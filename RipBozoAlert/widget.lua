--[[
Copyright 2023 noctellios
The RipBozo AddOn is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of RipBozo.

The RipBozo AddOn is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The RipBozo AddOn is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the RipBozo AddOn. If not, see <http://www.gnu.org/licenses/>.
--]]

local AceGUI = LibStub("AceGUI-3.0")
local LSM30 = LibStub("LibSharedMedia-3.0", true)

local sounds = LSM30:HashTable("sound")
sounds["0"] = "Interface\\AddOns\\RipBozo\\Sounds\\geshden.ogg"
sounds["1"] = "Interface\\AddOns\\RipBozo\\Sounds\\lmtf.ogg"
sounds["2"] = "Interface\\AddOns\\RipBozo\\Sounds\\tij.ogg"
sounds["3"] = "Interface\\AddOns\\RipBozo\\Sounds\\ct.ogg"
sounds["4"] = "Interface\\AddOns\\RipBozo\\Sounds\\kl.ogg"
sounds["5"] = "Interface\\AddOns\\RipBozo\\Sounds\\auil.ogg"
sounds["6"] = "Interface\\AddOns\\RipBozo\\Sounds\\kekw.ogg"

local TWITCHEMOTES_TimeSinceLastUpdate = 0
local TWITCHEMOTES_T = 0
local frameNum = 0
local alert_showing = false
local ripbozo_alert_frame = CreateFrame("FRAME", nil, UIParent)
local sound_handler = nil
local playing_sound = nil
ripbozo_alert_frame.text = ripbozo_alert_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
ripbozo_alert_frame.text:SetPoint("CENTER")
local path, size, flags = ripbozo_alert_frame.text:GetFont()
ripbozo_alert_frame.text:SetFont(path, 16, flags)
ripbozo_alert_frame:SetWidth(100)
ripbozo_alert_frame:SetHeight(100)
ripbozo_alert_frame:SetFrameStrata("TOOLTIP")
ripbozo_alert_frame:SetMovable(true)
ripbozo_alert_frame:EnableMouse(true)
ripbozo_alert_frame:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)

ripbozo_alert_frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.isMoving then
        local s = ripbozo_alert_frame:GetEffectiveScale();
        local x, y = ripbozo_alert_frame:GetCenter() 
        ripbozo_settings["x_pos"], ripbozo_settings["y_pos"] = x*s, y*s
        self:StopMovingOrSizing();
        self.isMoving = false;
  end
end)

ripbozo_alert_frame:SetScript("OnHide", function(self)
  if ( self.isMoving ) then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)

function RipBozo_DeathAlertPlay(entry)
    if alert_showing then
        ripbozo_alert_frame:Hide()
        StopSound(sounds_handler) 
    end
    alert_showing = true
    ripbozo_alert_frame.text:SetText("")
    ripbozo_alert_frame:Show()

    if (ripbozo_settings["sounds_enabled"]) then
        playing_sound, sounds_handler = PlaySoundFile(sounds[ripbozo_settings["alert_sound"]], "Master")
    end
    ripbozo_alert_frame:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", ripbozo_settings["x_pos"], ripbozo_settings["y_pos"])
    
    ripbozo_alert_frame:SetScript('OnUpdate', function(self, elapsed)
        if (TWITCHEMOTES_TimeSinceLastUpdate >= 0.033) then
            
            frameNum = math.floor((TWITCHEMOTES_T * 15) % 28)
            if (frameNum > 28) then
                frameNum = 0
            end
            local top = frameNum * 32;
            local bottom = top + 32;
            
            
            ripbozo_alert_frame.text:SetText(
                "|TInterface\\Addons\\RipBozo\\Emotes\\RIPBOZO.tga:48:48:0:0:32:1024:0:32:" .. top .. ":" .. bottom .. "|t\n\n" ..
                entry["name"] .. entry["comment"] ..
                "\n\n|TInterface\\Addons\\RipBozo\\Emotes\\cumboost.tga:48:48|t"
            )
            TWITCHEMOTES_TimeSinceLastUpdate = 0;
            
        end
        TWITCHEMOTES_T = TWITCHEMOTES_T + elapsed
        TWITCHEMOTES_TimeSinceLastUpdate = TWITCHEMOTES_TimeSinceLastUpdate + elapsed;
    end)
    

    if ripbozo_alert_frame.timer then
        ripbozo_alert_frame.timer:Cancel()
    end
    ripbozo_alert_frame.timer = C_Timer.NewTimer(20, function()
        ripbozo_alert_frame:Hide()
        alert_showing = false
    end)
end

function TwitchEmotesAnimator_OnUpdate(self, elapsed)
    if (TWITCHEMOTES_TimeSinceLastUpdate >= 0.033) then
        
        frameNum = math.floor((TWITCHEMOTES_TimeSinceLastUpdate * 15) % 28)
        if frameNum > 28 then
            frameNum = 0
        end
        local top = framenum * animdata.frameHeight;
        local bottom = top + animdata.frameHeight;
        ripbozo_alert_frame.text:SetPoint("CENTER")
        ripbozo_alert_frame.text:SetText(
            "|TInterface\\Addons\\RipBozo\\Emotes\\RIPBOZO.tga:48:48:0:0:32:1024:0:32:" .. top .. ":" .. bottom .. "|t\n\n" ..
            UnitName("player")
            .. " the "
            .. UnitClass("player")
            .. " "
            .. UnitRace("player")
            .. " has\ndied at level "
            .. UnitLevel("player")
            .. " in Elywynn Forest."
            .. "\n\n|TInterface\\Addons\\RipBozo\\Emotes\\cumboost.tga:48:48|t"
        )
        TWITCHEMOTES_TimeSinceLastUpdate = 0;
        
    end
    TWITCHEMOTES_TimeSinceLastUpdate = TWITCHEMOTES_TimeSinceLastUpdate + elapsed;
end