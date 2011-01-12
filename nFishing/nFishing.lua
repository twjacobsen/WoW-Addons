--[[ Config start ]]

local AUTOLOOT = true					--Enable auto-loot when fishing. This disables it when done fishing!
local FISHINGSET_NAME = "Fishing"		--Name of the EquipmentManager set to use when fishing
local ENABLE_SOUNDS = true				--Enable all sounds when fishing. Disables sound when done fishing!
local HIDE_NAMEPLATES = true				--Hide nameplates when fishing and out-of-combat

--[[ Config end ]]

-- Internal states and variables
local override = false
local isChanneling = false
local gearOn = true
local initialNamePlateState = GetCVar("nameplateShowEnemies")

-- Initialize the fishing button to click when double-right clicking
local btn = CreateFrame("Button", "FishingButton", UIParent, "SecureActionButtonTemplate")
btn:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0)
btn:SetFrameStrata("LOW")
btn:EnableMouse(true)
btn:RegisterForClicks("RightButtonUp")
btn:SetScript("PostClick", UnbindOverride)
btn:SetAttribute("type", "spell")
btn:SetAttribute("spell", "Fishing")
btn:SetAttribute("item", nil)
btn:SetAttribute("target-slot", nil)
btn:Hide()

-- Register some events
local a = CreateFrame("Frame",nil,Minimap)
a:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
a:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
a:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Determine wether user clicked twice or not
local function IsDoubleClick()
	if a.lastClickTime then
		local now = GetTime()
		local span = now - a.lastClickTime
		if span < 0.4 and span > 0.05 then
			a.lastClickTime = nil
			return true
		end
	end
	a.lastClickTime = GetTime()
	return false
end

-- Click the button to start fishing!
local function StartFishing(...)
	local button = select(2, ...)
	if button == "RightButton" then
		if IsDoubleClick() then
			SetOverrideBindingClick(btn, true, "BUTTON2", "FishingButton")
			override = true
		end
	end
end

-- Set vars
local function FishingMode(start)
	if start then
		gearOn = true
		if ENABLE_SOUNDS then
			SetCVar("Sound_EnableAllSound", "1")
		end
		if AUTOLOOT then
			SetCVar("autoLootDefault", "1")
		end
		if HIDE_NAMEPLATES then
			SetCVar("nameplateShowEnemies", 0)
			a:RegisterEvent("PLAYER_REGEN_ENABLED")
			a:RegisterEvent("PLAYER_REGEN_DISABLED")
		end
		WorldFrame:SetScript("OnMouseDown", StartFishing)
	else
		gearOn = false
		if ENABLE_SOUNDS then
			SetCVar("Sound_EnableAllSound", "0")
		end
		if AUTOLOOT then
			SetCVar("autoLootDefault", "0")
		end
		if HIDE_NAMEPLATES then
			SetCVar("nameplateShowEnemies", initialNamePlateState)
			a:UnregisterEvent("PLAYER_REGEN_ENABLED")
			a:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		WorldFrame:SetScript("OnMouseDown", nil)
	end
end

-- Unbind the button override
local function UnbindOverride()
	if override and isChanneling then
		ClearOverrideBindings(btn)
	end
end

-- Handle events
a:SetScript("OnEvent",
	function(_,event,arg1,arg2)
		if event == "EQUIPMENT_SWAP_FINISHED" then
			local set = arg2
			if set == "Fishing" or set == "fishing" then
				FishingMode(true)
			else
				FishingMode(false)
			end
			
			print(GetCVar("nameplateShowEnemies"))
		end
		
		if event == "UNIT_SPELLCAST_CHANNEL_START" then
			local name = arg1
			if name == "player" then
				isChanneling = true
				UnbindOverride()
			end
		end
		
		if event == "PLAYER_ENTERING_WORLD" then
			local itemArray = GetEquipmentSetItemIDs("Fishing") or GetEquipmentSetItemIDs("fishing")
			for i=1, #itemArray do
				if itemArray[i] then
					local info = GetItemInfo(itemArray[i])
					if info and not IsEquippedItem(info) then
						gearOn = false
					end
				end
			end

			FishingMode(gearOn)
		end
		
		if event == "PLAYER_REGEN_ENABLED" then
			SetCVar("nameplateShowEnemies", 0)
		end
		
		if event == "PLAYER_REGEN_DISABLED" then
			SetCVar("nameplateShowEnemies", 1)
		end
	end
)