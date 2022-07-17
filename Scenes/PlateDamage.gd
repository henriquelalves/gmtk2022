extends Plate

func activate(entity : Entity, dungeon):
	if entity is Player:
		entity.add_action("cor_damage", [0.2])
		Global.turns -= int(entity.get_top())
		return

	if entity is Monster:
		if entity.health - 1 <= 0:
			entity.alive = false
			entity.add_action("cor_dies", [])
			dungeon.kill_entity(entity)
		else:
			entity.health -= 1
			entity.add_action("cor_shake", [0.2])
		return
