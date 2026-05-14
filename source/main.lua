COLLISION_GROUPS = {
	PLAYER = 1,
	ENEMY = 2,
	PROJECTILE = 3,
	WALL = 4,
	EXPLOSIVE = 5,
	TRIGGER = 6,
	PICKUPS = 7,
	WATER = 8
}

-- NOTE: Core Imports
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/math"
import "CoreLibs/ui"

-- NOTE: Utilities
import "scripts/Misc/camera"
import "scripts/Misc/buoyancy"
import "scripts/Misc/saves"

-- NOTE: Game Objects
import "scripts/Entities/player"
import "scripts/Misc/water"
import "scripts/game_manager"
import "scripts/Misc/ui"
import "scripts/Scenes/mini_map_viewer"
import "scripts/Scenes/collection_menu"
import "scripts/Scenes/main_menu"
import "scripts/Scenes/intro"


local pd <const> = playdate
local gfx <const> = pd.graphics

local sprite_update <const> = gfx.sprite.update
local update_timers <const> = pd.timer.updateTimers

UISystem = UI()
GameManagerInstance = GameManager()

math.randomseed(playdate.getSecondsSinceEpoch())

gfx.setBackgroundColor(gfx.kColorClear)

local i = 0
pd.timer.keyRepeatTimerWithDelay(0, 800, function ()
	i += 1
	if i > 1 then
		i = 0
	end
end)

-- local menu = pd.getSystemMenu()
-- local menuItem, error = menu:addMenuItem("Clear Save", ClearSave)

-- TODO: I commented out the map because I don't like how it looks,
-- Try to come up with a new look so it can be brought back

local mainMenu = MainMenu()

function MainGameLoop()
	gfx.clear(gfx.kColorWhite)

	-- Draws a black background 
	oX, oY = gfx.getDrawOffset()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(-oX, -oY, 400, 320)

	UISystem:clear()

	GameManagerInstance:checkIfPlayerOutOfLevel()

	GameManagerInstance:checkDoorTriggers()

	GameManagerInstance:UpdatePhysicsComponentsBuoyancy()

	update_timers()
	GameManagerInstance:earlyUpdateObjects()
	GameManagerInstance:updateObjects()
	-- GameManagerInstance:UpdatePhysics()
	for i = 1, 2 do
		local Pairs = GameManagerInstance:CollisionDetection()
		GameManagerInstance:CollisionResolution(Pairs)
	end
	GameManagerInstance:calculateGrounded()
	GameManagerInstance:lateUpdateObjects()
	sprite_update()
	pd.frameTimer.updateTimers()

	-- NOTE: Update camera, moved out of the player
	-- GameManagerInstance.camera:lerp(GameManagerInstance.PlayerData.CameraTarget.x, GameManagerInstance.PlayerData.CameraTarget.y, 0.5, 0.05)
	local YSpeed = 0.05
	if GameManagerInstance.PlayerData.CameraTarget.y - GameManagerInstance.camera.y > 0 then
		YSpeed = 0.3
	end

	GameManagerInstance.camera:lerp(GameManagerInstance.PlayerData.CameraTarget.x, GameManagerInstance.PlayerData.CameraTarget.y, 0.2, YSpeed)

	pd.drawFPS(0, 0)
end

-- NOTE: In the simulator load the ldtk instantly so that the lua files exist without having to do anything
if pd.isSimulator then
	LDtk.load("levels/world.ldtk", false)
	LDtk.export_to_lua_files()
end

local intro

function MainMenuLoop()
	gfx.clear(gfx.kColorBlack)

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	if mainMenu.done then
		if not mainMenu.loadGame then
			-- NOTE: Uncomment below and remove the last two lines to bring back the intro sequence
			-- intro = Intro()
			-- pd.update = IntroLoop
			if not pd.isSimulator then
				LDtk.load("levels/world.ldtk", true)
			end
			GameManagerInstance:setUpGame(mainMenu.loadGame)
			pd.update = MainGameLoop
		else
			if not pd.isSimulator then
				LDtk.load("levels/world.ldtk", true)
			end
			GameManagerInstance:setUpGame(mainMenu.loadGame)
			pd.update = MainGameLoop
		end
	end
end

function IntroLoop()
	gfx.clear(gfx.kColorWhite)

	update_timers()
	sprite_update()
	pd.frameTimer.updateTimers()

	if intro.done then
		-- NOTE: On real hardware don't bother loading until someone starts the game

		if not pd.isSimulator then
			LDtk.load("levels/world.ldtk", true)
		end
		GameManagerInstance:setUpGame(mainMenu.loadGame)
		pd.update = MainGameLoop
	end
end

pd.update = MainMenuLoop

