local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/UIElements/ability_selection_menu"

class('AbilityPickup').extends(gfx.sprite)

function AbilityPickup:init(x, y, entity)
	self.entity = entity
	self:moveTo(x + 16, y + 16)
	self:setImage(gfx.image.new("images/AbilityPickup"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function AbilityPickup:pickup(player)
	player.bActive = false
	player.GameManager:collect(self.entity.iid)
	self.entity.fields.PickedUp = true

	OptionBox("Pick a weapon", self.entity.fields.Abilities, function (index, string)
		PopupTextBox(AbilityExplanation[string], 4000, 10)
		player.setAbilityA(player, Abilities[string], string)
	end)
	-- AbilitySelectionMenu(player, self.entity)

	self:remove()
end
