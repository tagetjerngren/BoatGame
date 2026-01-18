import "libraries/LDtk"

-- NOTE: Abilities
import "scripts/entities/abilities/abilityPickup"
import "scripts/entities/abilities/changeSizeDevice"
import "scripts/entities/abilities/companionPickup"
import "scripts/entities/abilities/interest"
import "scripts/entities/abilities/invisibilityDevice"
import "scripts/entities/abilities/lantern"
import "scripts/entities/abilities/submerge"
import "scripts/entities/abilities/teleportationDevice"
import "scripts/entities/abilities/waterWheel"
import "scripts/entities/abilities/wheelPickup"

-- NOTE: Hazards
import "scripts/entities/hazards/bouncingSpike"
import "scripts/entities/hazards/diagonalEnemy"
import "scripts/entities/hazards/laser"
import "scripts/entities/hazards/mine"
import "scripts/entities/hazards/mooredMine"
import "scripts/entities/hazards/spikeRail"
import "scripts/entities/hazards/spinningSpikeBalls"
import "scripts/entities/hazards/staticGun"
import "scripts/entities/hazards/swayGun"

-- NOTE: Mechanics
import "scripts/entities/mechanics/block16"
import "scripts/entities/mechanics/blockedWall"
import "scripts/entities/mechanics/button"
import "scripts/entities/mechanics/companionDoor"
import "scripts/entities/mechanics/darkness"
import "scripts/entities/mechanics/detector"
import "scripts/entities/mechanics/door"
import "scripts/entities/mechanics/DoorTrigger"
import "scripts/entities/mechanics/foliage"
import "scripts/entities/mechanics/movingPlatform"
import "scripts/entities/mechanics/oneWayDoor"
import "scripts/entities/mechanics/projectileButton"
import "scripts/entities/mechanics/sightDoor"

-- NOTE: NPCs
import "scripts/entities/npcs/bigMan"
import "scripts/entities/npcs/theTall"
import "scripts/entities/npcs/theUpgrader"

-- NOTE: Misc
import "scripts/entities/player"
import "scripts/entities/coin"
import "scripts/entities/bigCoin"
import "scripts/entities/playerCorpse"
import "scripts/entities/savePoint"
import "scripts/entities/ui"
import "scripts/entities/companion"
import "scripts/entities/plant"
import "scripts/entities/sample"
import "scripts/WaterLevelChanger"

local pd <const> = playdate
local gfx <const> = pd.graphics

local WaterParticleDensity = 50

class('Scene').extends()

function Scene:init(bLoadGame)
	self.miniMap = pd.datastore.readImage("MiniMap/miniMap")
	if self.miniMap then
		self.miniMapWithHighlight = pd.datastore.readImage("MiniMap/displayMiniMap")
	else
		self.miniMap = gfx.image.new(1000, 1000)
		self.miniMapWithHighlight = self.miniMap:copy()
	end

	self.menu = pd.getSystemMenu()
	self.menuItem, self.error = self.menu:addMenuItem("Swap Crank", function()
		self.water.bOldSystem = not self.water.bOldSystem
	end)

	self.menuItem2, error = self.menu:addMenuItem("View Samples", function ()
		self:DeactivatePhysicsComponents()
		CollectionMenu(self)
	end)

	self.ActivePhysicsComponents = {}

	self.ui = UISystem
	self.songManager = pd.sound.fileplayer.new()
	local SaveData = LoadGame(self)
	if bLoadGame then
		self.collectedEntities = SaveData["CollectedEntities"]
		self.player = Player(SaveData["PlayerX"], SaveData["PlayerY"], gfx.image.new("images/Boat"), 5, self)
		self.player.coins = SaveData["PlayerCoins"]
		self.player.weaponTier = SaveData["PlayerWeaponTier"]
		self.player.lightRadius = SaveData["PlayerLightRadius"]
		self.player.bCanTeleport = SaveData["PlayerCanTeleport"]
		self.player.bHasInterest = SaveData["PlayerHasInterest"]
		self.player.bHasSubmerge = SaveData["PlayerHasSubmerge"]
		self.player.bHasInvisibilityDevice = SaveData["PlayerHasInvisibilityDevice"]
		self.player.bHasChangeSizeDevice = SaveData["PlayerHasChangeSizeDevice"]
		self.player.bHasWheels = SaveData["PlayerHasWheels"]
		self.player.AbilityA = Abilities[SaveData["PlayerAbilityAName"]]
		self.player.AbilityAName = SaveData["PlayerAbilityAName"]
		self.player.AbilityB = Abilities[SaveData["PlayerAbilityBName"]]
		self.player.AbilityBName = SaveData["PlayerAbilityBName"]
		self.player.PassiveAbility = Abilities[SaveData["PlayerPassiveAbilityName"]]
		self.player.PassiveAbilityName = SaveData["PlayerPassiveAbilityName"]
		if SaveData["PlayerDirection"] == -1 then
			self.player:setImageFlip(gfx.kImageFlippedX)
		end
		if SaveData["PlayerHasCompanion"] then
			self.player.companion = Companion(self.player.x, self.player.y, self.player)
		end
		local level_rect = LDtk.get_rect(SaveData["CurrentLevel"])
		if not level_rect then
			print("INVALID LEVEL IN SAVE FILE")
			SaveData["CurrentLevel"] = "Level_0"
			level_rect = LDtk.get_rect(SaveData["CurrentLevel"])
		end
		self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
		self.water = Water(SaveData["WaterHeight"], self.LevelWidth, 0, self.LevelHeight, 0.2, WaterParticleDensity)
		self.water.bActive = SaveData["WaterWheelInPossession"]
		self.water.bFirstCollection = SaveData["WaterWheelCollected"]
		self:goToLevel(SaveData["CurrentLevel"])
		if SaveData["PlayerCorpseX"] then
			self.playerCorpse = PlayerCorpse(SaveData["PlayerCorpseX"], SaveData["PlayerCorpseY"], SaveData["PlayerCorpseLevel"], self, SaveData["PlayerCorpseCoins"], SaveData["PlayerCorpseDirection"])
		end

		-- If the data exists then put it on the player
		if SaveData["SampleCollection"] then
			self.player.sampleCollection = SaveData["SampleCollection"]
		end
	else
		self.collectedEntities = {}
		self.player = Player(0, 0, gfx.image.new("images/Boat"), 5, self)
		local level_rect = LDtk.get_rect("Level_0")
		self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
		self.water = Water(100, self.LevelWidth, 0, self.LevelHeight, 0.1, WaterParticleDensity)
		self:goToLevel("Level_0")
		self.player:moveTo(self.SpawnX, self.SpawnY)
		self.player.PhysicsComponent:setPosition(self.SpawnX, self.SpawnY)
		self.camera:center(self.player.x, self.player.y)
		-- self.water.height = self.SpawnY
		self.water:SetHeight(self.SpawnY)
	end
end

function Scene:collect(entityIid)
	self.collectedEntities[entityIid] = true
	table.insert(self.collectedEntities, entityIid)
end

function Scene:enterRoom(door, direction)
	print("Entering room: "..door.TargetLevel)
	local xDiff, yDiff
	-- Position the player
	if direction == "EAST" or direction == "WEST" then
		xDiff = 0
		yDiff = door.TargetY - door.y
		if direction == "WEST" then
			self.player:moveTo(door.TargetX, self.player.y + yDiff)
		else
			self.player:moveTo(door.TargetX + 16, self.player.y + yDiff)
		end
	elseif direction == "NORTH" or direction == "SOUTH" then
		xDiff = door.TargetX - door.x
		yDiff = 0
		self.player:moveTo(self.player.x + xDiff, door.TargetY)
	end

	-- Set their velocity to zero
	self.player.PhysicsComponent:setVelocity(0, 0)
	-- self.player.PhysicsComponent.Velocity = playdate.geometry.vector2D.new(0, 0)

	-- Set the water height and width
	local level_rect = LDtk.get_rect(door.TargetLevel)
	if direction == "NORTH" then
		-- self.water.height = level_rect.height - 16
		self.water:SetHeight(level_rect.height - 16)
	elseif direction == "SOUTH" then
		-- self.water.height = 32
		self.water:SetHeight(32)
		self.player.y = 32
		self.player.PhysicsComponent.position.y = 32
	else
		-- self.water.height += yDiff
		self.water:SetHeight(self.water.height + yDiff)
	end
	-- self.water.width = level_rect.width
	self.water:SetWidth(level_rect.width)

	-- Set the waters limits
	self.water.lowerBound = 0 - 20
	self.water.upperBound = level_rect.height + 20

	self:goToLevel(door.TargetLevel)

	self.player.PhysicsComponent:setPosition(self.player.x, self.player.y)
	self:SetPhysicsComponentsPosition()

	-- NOTE: Bypass the lerp so the camera snaps to place when going to new level
	self.camera:center(self.player.x, self.player.y)

end

function Scene:reloadLevel()
	self:goToLevel(self.currentLevel)

end

local miniMapRatio = 25

function Scene:updateMiniMapHighlight()
	local levelInfo = LDtk.get_rect(self.currentLevel)
	self.miniMapWithHighlight = self.miniMap:copy()
	gfx.lockFocus(self.miniMapWithHighlight)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(100 + levelInfo.x/miniMapRatio, 100 + levelInfo.y/miniMapRatio, levelInfo.width/miniMapRatio, levelInfo.height/miniMapRatio - 1)
	gfx.unlockFocus()
end

function Scene:updateMiniMap(level_name)
	gfx.lockFocus(self.miniMap)
	local levelInfo = LDtk.get_rect(level_name)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRect(100 + levelInfo.x/miniMapRatio, 100 + levelInfo.y/miniMapRatio, levelInfo.width/miniMapRatio, levelInfo.height/miniMapRatio)
	gfx.unlockFocus(self.miniMap)
end

function Scene:goToLevel(level_name)

	self.currentLevel = level_name
	if self.entityInstance then
		for _, entity in pairs(self.entityInstance) do
			if entity.destructor then
				entity:destructor()
			end
		end
	end
	gfx.sprite.removeAll()
	self.player:add()
	self.water:add()
	self.ui:add()
	if self.playerCorpse and self.playerCorpse.level == level_name then
		self.playerCorpse:add()
	end
	if self.player.companion then
		self.player.companion:add()
		self.player.companion:moveTo(self.player.x, self.player.y)
	end

	-- Draw data to minimap
	self:updateMiniMap(level_name)
	self:updateMiniMapHighlight()
	-- self:highlightLevelMiniMap(level_name)

	self.entityInstance = {}

	self.ActivePhysicsComponents = {}
	table.insert(self.ActivePhysicsComponents, self.player.PhysicsComponent)

	-- NOTE: This adds in all of the tiles and their collisions
	for layer_name, layer in pairs(LDtk.get_layers(level_name)) do
		if layer.tiles then
			local tilemap = LDtk.create_tilemap(level_name, layer_name)
			local layerSprite = gfx.sprite.new()
			layerSprite:setTilemap(tilemap)
			layerSprite:setCenter(0,0)
			layerSprite:moveTo(0,0)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			local emptyTiles = LDtk.get_empty_tileIDs(level_name, "Solid", layer_name)
			if emptyTiles then
				local tileSprites = gfx.sprite.addWallSprites(tilemap, emptyTiles)
				for i = 1, #tileSprites do
					tileSprites[i]:setGroups({COLLISION_GROUPS.WALL})
				end
			end
		end
	end

	-- NOTE: Spawns in all of the entities in the level
	-- TODO: THE DOOR RELIES ON THE BUTTON BEING ALREADY SPAWNED IN; MAKE IT SO THAT THE ORDER DOESN'T MATTER
	local lateEntities = {}
	for _, entity in ipairs(LDtk.get_entities(level_name)) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name

		if entityName == "RoomTransition" then
			self.entityInstance[entity.iid] = DoorTrigger(entityX, entityY, entity)
		elseif entityName == "Mine" then
			local MineInstance = Mine(entityX, entityY)
			table.insert(self.ActivePhysicsComponents, MineInstance.PhysicsComponent)
			self.entityInstance[entity.iid] = MineInstance
		elseif entityName == "MooredMine" then
			local MineInstance = MooredMine(entityX, entityY, entity)
			table.insert(self.ActivePhysicsComponents, MineInstance.PhysicsComponent)
			self.entityInstance[entity.iid] = MineInstance
		elseif entityName == "SpawnPoint" then
			self.SpawnX = entityX + 16
			self.SpawnY = entityY + 32
		elseif entityName == "AbilityPickup" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = AbilityPickup(entityX, entityY, entity)
		elseif entityName == "WaterWheel" then
			self.entityInstance[entity.iid] = WaterWheel(entityX, entityY, entity, self.water)
		elseif entityName == "Coin" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = Coin(entityX, entityY, entity)
		elseif entityName == "BigCoin" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = BigCoin(entityX, entityY, entity)
		elseif entityName == "BlockedWall" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = BlockedWall(entityX, entityY, entity)
		elseif entityName == "OneWayDoor" then
			self.entityInstance[entity.iid] = OneWayDoor(entityX, entityY, entity, 0)
		elseif entityName == "Button" then
			self.entityInstance[entity.iid] = Button(entityX, entityY, entity)
		elseif entityName == "ProjectileButton" then
			self.entityInstance[entity.iid] = ProjectileButton(entityX, entityY, entity)
		elseif entityName == "Door" then
			table.insert(lateEntities, entity)
		elseif entityName == "SightDoor" then
			table.insert(lateEntities, entity)
		elseif entityName == "SavePoint" then
			self.entityInstance[entity.iid] = SavePoint(entityX, entityY, self.currentLevel)
		elseif entityName == "Foliage" then
			self.entityInstance[entity.iid] = Foliage(entityX, entityY, self)
		elseif entityName == "Detector" then
			self.entityInstance[entity.iid] = Detector(entityX, entityY, entity)
		elseif entityName == "Block16" then
			self.entityInstance[entity.iid] = Block16(entityX, entityY)
		elseif entityName == "SpinningSpikeBalls" then
			self.entityInstance[entity.iid] = SpinningSpikeBalls(entityX, entityY, entity)
		elseif entityName == "SpikeRail" then
			self.entityInstance[entity.iid] = SpikeRail(entityX, entityY, entity)
		elseif entityName == "DiagonalEnemy" then
			self.entityInstance[entity.iid] = DiagonalEnemy(entityX, entityY, entity)
		elseif entityName == "SwayGun" then
			self.entityInstance[entity.iid] = SwayGun(entityX, entityY, entity)
		elseif entityName == "StaticGun" then
			self.entityInstance[entity.iid] = StaticGun(entityX, entityY, entity)
		elseif entityName == "Laser" then
			self.entityInstance[entity.iid] = Laser(entityX, entityY, entity)
		elseif entityName == "MovingPlatform" then
			self.entityInstance[entity.iid] = MovingPlatform(entityX, entityY, entity)
		elseif entityName == "Darkness" then
			self.entityInstance[entity.iid] = Darkness(self.player)
		elseif entityName == "Lantern" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = Lantern(entityX, entityY, entity)
		elseif entityName == "Interest" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = Interest(entityX, entityY, entity)
		elseif entityName == "Submerge" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = Submerge(entityX, entityY, entity)
		elseif entityName == "TeleportationDevice" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = TeleportationDevice(entityX, entityY, entity)
		elseif entityName == "CompanionDoor" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = CompanionDoor(entityX, entityY, entity)
		elseif entityName == "CompanionPickup" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = CompanionPickup(entityX, entityY, entity)
		elseif entityName == "InvisibilityDevice" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = InvisibilityDevice(entityX, entityY, entity)
		elseif entityName == "ChangeSizeDevice" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = ChangeSizeDevice(entityX, entityY, entity)
		elseif entityName == "WheelPickup" and not self.collectedEntities[entity.iid] then
			self.entityInstance[entity.iid] = WheelPickup(entityX, entityY, entity)
		elseif entityName == "TheUpgrader" then
			self.entityInstance[entity.iid] = TheUpgrader(entityX, entityY)
		elseif entityName == "TheTall" then
			self.entityInstance[entity.iid] = TheTall(entityX, entityY)
		elseif entityName == "BigMan" then
			self.entityInstance[entity.iid] = BigMan(entityX, entityY)
		elseif entityName == "BouncingSpike" then
			self.entityInstance[entity.iid] = BouncingSpike(entityX, entityY, entity)
		elseif entityName == "Plant" then
			self.entityInstance[entity.iid] = Plant(entityX, entityY)
		elseif entityName == "Sample" then
			self.entityInstance[entity.iid] = Sample(entityX, entityY, entity, self.collectedEntities[entity.iid])
		elseif entityName == "WaterLevelChanger" then
			self.entityInstance[entity.iid] = WaterLevelChanger(entityX, entityY, entity)
		elseif entityName == "SpikeBall" then
			self.entityInstance[entity.iid] = SpikeBall(entityX + 16, entityY + 16)
		end
	end

	-- NOTE: This processes the entities that are dependent on other entities, so that those entities really exist by this point
	for _, entity in ipairs(lateEntities) do
		local entityX, entityY = entity.position.x, entity.position.y
		local entityName = entity.name
		if entityName == "Door" then
			self.entityInstance[entity.iid] = Door(entityX, entityY, entity, self.entityInstance[entity.fields.Button.entityIid])
		elseif entityName == "SightDoor" then
			self.entityInstance[entity.iid] = SightDoor(entityX, entityY, entity, self.entityInstance[entity.fields.Detector.entityIid])
		end
	end

	-- NOTE: Keeps the camera in the level bounds
	local level_rect = LDtk.get_rect(level_name)
	self.LevelWidth, self.LevelHeight = level_rect.width, level_rect.height
	self.camera = Camera(self.player.x, self.player.y, 0, 0, self.LevelWidth, self.LevelHeight)

	-- Sets the water stuff
	-- self.water.width = level_rect.width
	self.water:SetWidth(level_rect.width)

	-- Set the waters limits
	local WaterMaxHeight = LDtk.get_custom_data(level_name, "WaterMaxHeight")
	self.water.lowerBound = WaterMaxHeight - 20
	self.water.upperBound = level_rect.height + 20

	if self.songName ~= LDtk.get_custom_data(level_name, "Song") then
		self.songName = LDtk.get_custom_data(level_name, "Song")
		if self.songName then
			local song = string.sub(self.songName, 4, #self.songName - 4)

			self.songManager:stop()
			self.songManager = pd.sound.fileplayer.new(song)
			self.songManager:play(0)
		else
			-- If there is no song set in ldtk then play nothing
			self.songManager:stop()
		end
	end
end

function Scene:DeactivatePhysicsComponents()
	self.PhysicsComponents = self.ActivePhysicsComponents
	self.ActivePhysicsComponents = {}
end

function Scene:ActivatePhysicsComponents()
	self.ActivePhysicsComponents = self.PhysicsComponents
end

function Scene:UpdatePhysicsComponentsBuoyancy()
	for i = 1, #self.ActivePhysicsComponents do
		if self.ActivePhysicsComponents[i].bBuoyant then
			-- local buoyancyForces = CalculateBuoyancy(self.water.height, self.ActivePhysicsComponents[i].position.y, 50, 0.3, 5.5, self.ActivePhysicsComponents[i])
			local buoyancyForces = CalculateBuoyancy(self.water:getHeight(self.ActivePhysicsComponents[i].position.x), self.ActivePhysicsComponents[i].position.y, 50, 0.3, 5.5, self.ActivePhysicsComponents[i])
			self.ActivePhysicsComponents[i]:addForce(buoyancyForces)

			if buoyancyForces and buoyancyForces.y ~= 0 and self.ActivePhysicsComponents[i].velocity.y ~= 0 then
				self.water:Poke(self.ActivePhysicsComponents[i].position.x, buoyancyForces.y * 0.3)
			end
		end
	end
end

function Scene:SetPhysicsComponentsPosition()
	-- for i = 1, #self.ActivePhysicsComponents do
	-- 	if self.ActivePhysicsComponents[i].bBuoyant then
	-- 		self.ActivePhysicsComponents[i]:setVelocity(0, 0)
	--
	-- 		local Component = self.ActivePhysicsComponents[i]
	-- 		local _, point = Raycast(Component.position.x, Component.position.y, 0, self.water.height - Component.position.y)
	-- 		if point then
	-- 			print("Ray hit")
	-- 			self.ActivePhysicsComponents[i]:setPosition(self.ActivePhysicsComponents[i].position.x, point.y)
	-- 		else
	-- 			print("Ray missed")
	-- 			self.ActivePhysicsComponents[i]:setPosition(self.ActivePhysicsComponents[i].position.x, self.water.height)
	-- 		end
	-- 	end
	-- end
end
