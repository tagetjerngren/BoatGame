class('PlayerData').extends()

-- NOTE: Stores generic info on the player that should persist between boat mode and person mode

function PlayerData:init()
	self.bHoldingObject = false
	self.HeldImage = nil
	self.HeldObject = nil

	self.coins = 0
end
