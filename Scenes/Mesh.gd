extends MeshInstance

var target_basis : Basis

func _ready():
	target_basis = transform.basis

func _process(delta):
	transform.basis = transform.basis.slerp(target_basis, delta*8)

func roll(dir : Vector2):
	target_basis = target_basis.rotated(Vector3(dir.y,0,-dir.x), deg2rad(90))
