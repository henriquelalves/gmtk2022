extends Plate

export(int) var damage

func activate(entity : Entity, dungeon):
	if entity is Player:
		entity.add_action("cor_shake", [0.2])
		Global.turns -= damage
		return

	if entity is Monster:
		if entity.health - damage <= 0:
			entity.alive = false
			entity.add_action("cor_dies", [])
			dungeon.kill_entity(entity)
		else:
			entity.health -= damage
			entity.add_action("cor_shake", [0.2])
		return
