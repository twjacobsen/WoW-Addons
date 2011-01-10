--[[ Config start ]]

local ITEMQUALITY = 2					--Highest item quality to auto-roll for (4 = epic, 3 = blue, 2 = green)
local DISENCHANT = true					--Disenchant if possible
local NOWARN = true						--Dismiss BoP / DE warnings for the Item Quality defined above

--[[ Config end ]]

local f = CreateFrame("Frame")
local g = CreateFrame("Frame")
local h = {}

f:RegisterEvent("START_LOOT_ROLL")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
g:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
g:RegisterEvent("CONFIRM_LOOT_ROLL")
f:SetScript("OnEvent", function(self, event, id)
	if event == "PLAYER_ENTERING_WORLD" then
		--Fetch primary professions
		local prim, sec = GetProfessions()
		h[1] = GetProfessionInfo(prim)
		h[2] = GetProfessionInfo(sec)
		
		--Unregister event - professions have been loaded.
		f:UnregisterEvent("PLAYER_ENTERING_WORLD")
	else
		if id then
			if(select(4, GetLootRollItemInfo(id)) < (ITEMQUALITY+1)) then
				if(DISENCHANT and select(8, GetLootRollItemInfo(id))) then
					RollOnLoot(id, 3)	--Roll DE
				else
					RollOnLoot(id, 2)	--Roll greed
				end
			end
		end
	end
end)
--Dismiss BoP and DE warnings
g:SetScript("OnEvent", function(_,_,id,type)
	if(id and (NOWARN or select(4, GetLootRollItemInfo(id)) < (ITEMQUALITY+1))) then
		ConfirmLootRoll(id, type)
	end
end)