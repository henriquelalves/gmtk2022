extends Plate

func activate(entity : Entity, dungeon):
	if entity is Player:
		var damage = int(entity.get_top())
		entity.add_action("cor_damage", [0.2])
		dungeon.damage_player(damage)
		Global.turns -= damage
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
