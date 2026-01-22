local gfx <const> = playdate.graphics

-- NOTE: This is a sprite so that it gets wiped out by the gamemanager, it doesn't use anything only inherent to sprites but it means I could avoid adding an additional method for deleting doortriggers
class('DoorTrigger').extends(gfx.sprite)

function DoorTrigger:init(x, y, entity)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self:setCollideRect(0, 0, entity.size.width, entity.size.height)
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER})
	self:add()
	local fields = entity.fields
	self.bTransitionOnEnter = fields.TransitionOnEnter
	self.TargetLevel = LDtk.get_level_name(fields.Target.levelIid)

	for _, e in ipairs(LDtk.get_entities(self.TargetLevel)) do
		if e.iid == fields.Target.entityIid then
			self.TargetX = e.position.x
			self.TargetY = e.position.y
			break
		end
	end
end
