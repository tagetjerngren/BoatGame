local ds <const> = playdate.datastore

function LoadGame()
	return ds.read()
	-- local SaveData = ds.read()
	-- if SaveData then
	-- 	printTable(SaveData)
	-- 	-- GameManager:goToLevel(info.CurrentLevel)
	-- 	return true
	-- else
	-- 	return false
	-- end
end

function ClearSave()
	local emptyMap = playdate.graphics.image.new(1000, 1000)
	ds.writeImage(emptyMap, "MiniMap/miniMap")
	ds.writeImage(emptyMap, "MiniMap/displayMiniMap")
	ds.delete()
end

function SaveGame(GameManager, PositionX, PositionY)
	local SaveData = {
		-- Positioning
		["CurrentLevel"] = GameManager.currentLevel,
		["PlayerX"] = PositionX,
		["PlayerY"] = PositionY,
		["PlayerDirection"] = GameManager.player.direction,

		-- Player Attributes
		["PlayerCoins"] = GameManager.player.coins,
		["PlayerLightRadius"] = GameManager.player.lightRadius,
		["PlayerCanTeleport"] = GameManager.player.bCanTeleport,
		["PlayerHasInterest"] = GameManager.player.bHasInterest,
		["PlayerHasSubmerge"] = GameManager.player.bHasSubmerge,
		["PlayerHasInvisibilityDevice"] = GameManager.player.bHasInvisibilityDevice,
		["PlayerHasChangeSizeDevice"] = GameManager.player.bHasChangeSizeDevice,
		["PlayerHasWheels"] = GameManager.player.bHasWheels,
		["PlayerAbilityAName"] = GameManager.player.AbilityAName,
		["PlayerAbilityBName"] = GameManager.player.AbilityBName,
		["PlayerPassiveAbilityName"] = GameManager.player.PassiveAbilityName,
		["PlayerWeaponTier"] = GameManager.player.weaponTier,

		-- Water
		["WaterHeight"] = GameManager.water.height,
		["WaterWheelCollected"] = GameManager.water.bFirstCollection,
		["WaterWheelInPossession"] = GameManager.water.bWaterWheelPossessed,

		-- Collected Entities (Coins, Abilities, and the Water Wheel)
		["CollectedEntities"] = GameManager.collectedEntities
	}

	-- Player Corpse
	if GameManager.playerCorpse then
		SaveData["PlayerCorpseX"] = GameManager.playerCorpse.x + 16
		SaveData["PlayerCorpseY"] = GameManager.playerCorpse.y + 16
		SaveData["PlayerCorpseDirection"] = GameManager.playerCorpse.direction
		SaveData["PlayerCorpseCoins"] = GameManager.playerCorpse.coins
		SaveData["PlayerCorpseLevel"] = GameManager.playerCorpse.level
	end

	SaveData["SampleCollection"] = GameManager.player.sampleCollection

	if GameManager.player.companion then
		SaveData["PlayerHasCompanion"] = true
	end

	ds.writeImage(GameManager.miniMap, "MiniMap/miniMap")
	ds.writeImage(GameManager.miniMapWithHighlight, "MiniMap/displayMiniMap")

	ds.write(SaveData)
end
