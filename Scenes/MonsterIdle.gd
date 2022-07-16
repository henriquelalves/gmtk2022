extends Monster

func try_moving(player_pos : Vector2, monster_pos : Vector2) -> MonsterAction:
	var action = MonsterAction.new()
	action.type = MonsterActionType.IDLE
	return action
