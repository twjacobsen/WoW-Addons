--[[ Config start ]]

local AUTOLOOT = true					--Enable auto-loot when fishing. This disables it when done fishing!
local FISHINGSET_NAME = "Fishing"		--Name of the EquipmentManager set to use when fishing
local ENABLE_SOUNDS = true				--Enable all sounds when fishing. Disables sound when done fishing!

--[[ Config end ]]

local override = false
local isChanneling = false
local gearOn = true

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

local a = CreateFrame("Frame",nil,Minimap)
a:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
a:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
a:RegisterEvent("ADDON_LOADED")

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

local function StartFishing(...)
	local button = select(2, ...)
	if button == "RightButton" then
		if IsDoubleClick() then
			SetOverrideBindingClick(btn, true, "BUTTON2", "FishingButton")
			override = true
		end
	end
end

local function FishingMode(start)
	if start then
		gearOn = true
		if ENABLE_SOUNDS then
			SetCVar("Sound_EnableAllSound", "1")
		end
		if AUTOLOOT then
			SetCVar("autoLootDefault", "1")
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
		WorldFrame:SetScript("OnMouseDown", nil)
	end
end

local function UnbindOverride()
	if override and isChanneling then
		ClearOverrideBindings(btn)
	end
end

a:SetScript("OnEvent",
	function(_,event,arg1,arg2)
		if event == "EQUIPMENT_SWAP_FINISHED" then
			local set = arg2
			if set == "Fishing" or set == "fishing" then
				FishingMode(true)
			else
				FishingMode(false)
			end
		end
		
		if event == "UNIT_SPELLCAST_CHANNEL_START" then
			local name = arg1
			if name == "player" then
				isChanneling = true
				UnbindOverride()
			end
		end
		
		if event == "ADDON_LOADED" and arg1 == "nFishing" then
			local itemArray = GetEquipmentSetItemIDs("Fishing") or GetEquipmentSetItemIDs("fishing")
			for i=1, #itemArray do
				if itemArray[i] then
					local info = GetItemInfo(itemArray[i])
					if info and not IsEquippedItem(info) then
						gearOn = false
					end
				end
			end

			if gearOn then
				FishingMode(true)
			else
				FishingMode(false)
			end
		end
	end
)