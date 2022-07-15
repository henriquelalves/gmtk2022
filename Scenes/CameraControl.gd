extends Spatial

func follow(obj : Spatial):
	get_parent().remove_child(self)
	obj.add_child(self)
	translate(Vector3.ZERO)
