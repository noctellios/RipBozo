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

ripbozo_settings = ripbozo_settings or {
    ["enabled"] = true,
    ["sounds_enabled"] = true,
    ["alert_sound"] = "0",
    ["x_pos"] = 120,
    ["y_pos"] = 415
}

ripbozo_watchlist = ripbozo_watchlist or {}

local f = CreateFrame("Frame")

local defaults = {
	playSound = true
}

function f:OnEvent(event, addOnName)
	if addOnName == "RipBozo" then
		ripbozo_settings = ripbozo_settings or CopyTable(defaults)
		self:InitializeOptions()
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

local optionsframe = nil
function f.InitializeOptions()
    options = {
        type = "group",
        args = {
            enable = {
                name = "Enable",
                desc = "Enables / disables the addon",
                type = "toggle",
                width = 1.5,
                order = 0,
                set = function(info,val) ripbozo_settings["enabled"] = val end,
                get = function(info) return ripbozo_settings["enabled"] end
            },
            test = {
                type = "execute",
                desc = "Fake alert for 20 seconds. Click and drag to position.",
                name = "Test",
                width = 1.5,
                order = 1,
                disabled = function () return not ripbozo_settings["enabled"] end,
                func = function()
                    test_data = {
                        ["name"] = "Noctellios",
                        ["comment"] = " - this goober..."
                    }
                    RipBozo_DeathAlertPlay(test_data)
                end
            },
            enableSound = {
                name = "Enable Sounds",
                desc = "Enables / disables the alert sounds",
                type = "toggle",
                width = 1.5,
                order = 2,
                set = function(info,val) ripbozo_settings["sounds_enabled"] = val end,
                get = function(info) return ripbozo_settings["sounds_enabled"] end
            },
            sound = {
                name = "Alert Sound",
                desc = "Selects the alert sound to play",
                type = "select",
                style = "dropdown",
                width = 1.5,
                order = 3,
                disabled = function() return not ripbozo_settings["sounds_enabled"] end,
                values = {
                    ["0"] = "Geshden",
                    ["1"] = "Whiney",
                    ["2"] = "Guitar",
                    ["3"] = "Percussive",
                    ["4"] = "Heavy",
                },
                set = function(info,val) ripbozo_settings["alert_sound"] = val end,
                get = function(info) return ripbozo_settings["alert_sound"] end
            },
            charName = {
                type = "input",
                name = "Character",
                order = 4,
                set = function(info,val) ripbozo_settings["temp_char"] = val end,
                get = function(info) return ripbozo_settings["temp_char"] end
            },
            comment = {
                type = "input",
                name = "Comment",
                width = "double",
                order = 5,
                set = function(info,val) ripbozo_settings["temp_comment"] = val end,
                get = function(info) return ripbozo_settings["temp_comment"] end
            },
            commit = {
                type = "execute",
                name = "Add",
                width = "half",
                order = 6,
                disabled = function () return not ripbozo_settings["temp_char"] end,
                func = function()
                    ripbozo_watchlist[ripbozo_settings["temp_char"]] = {
                        ["name"] = ripbozo_settings["temp_char"],
                        ["comment"] = ripbozo_settings["temp_comment"]
                    } 
                    ripbozo_settings["temp_char"] = nil
                    ripbozo_settings["temp_comment"] = nil
                end
            },
            select = {
                type = "select",
                name = "Watchlist",
                width = 3,
                order = 7,
                values = function() 
                    list = {}
                    local temp_entry = ""
                    for k,v in pairs(ripbozo_watchlist) do
                        temp_entry = ""
                        if v.name ~= nil then 
                            temp_entry = v.name
                            if v.comment ~= nil then
                                temp_entry = temp_entry .. " - " .. v.comment
                            end
                            list[k] = temp_entry
                        end
                    end
                    return list
                end,
                get = function(info) return ripbozo_settings["temp_remove"] end,
                set = function(info, val) ripbozo_settings["temp_remove"] = val end
            },
            remove = {
                type = "execute",
                name = "Remove",
                width = "half",
                order = 8,
                disabled = function() return not ripbozo_settings["temp_remove"] end,
                func = function()
                    ripbozo_watchlist[ripbozo_settings["temp_remove"]] = nil
                    ripbozo_settings["temp_remove"] = nil
                end
            },
        }
    }

    if optionsframe == nil then
		LibStub("AceConfig-3.0"):RegisterOptionsTable("RipBozo", options)
		optionsframe = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("RipBozo", "RipBozo", nil)
	end
end

SLASH_RIPBOZO1 = "/rb"
SLASH_RIPBOZO2 = "/ripbozo"

SlashCmdList["RIPBOZO"] = function(msg, editBox)
    InterfaceOptionsFrame_Show()
	InterfaceOptionsFrame_OpenToCategory("RipBozo")
end


local function newEntry(_player_data, _checksum, num_peer_checks, in_guild)
    if (not ripbozo_settings["enabled"]) then return end
    if (_player_data["name"] == nil) then return end

    local found = false
    local dName = _player_data["name"]:lower()
    for k,v in pairs(ripbozo_watchlist) do
        if (((v.name:lower() == dName) or string.match(_player_data["name"], v.name)) and (not found)) then 
            if (v.comment == nil) then 
                _player_data["comment"] = ""
            else
                _player_data["comment"] = " - " .. v.comment
            end
            found = true
            RipBozo_DeathAlertPlay(_player_data)
        end
    end

end

-- Hook to DeathNotificationLib
DeathNotificationLib_HookOnNewEntry(newEntry)

