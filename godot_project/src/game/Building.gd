extends YSort

func _ready():
	$Floor.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body : CollisionObject2D):
	# TODO: Make the roof dissapear here!
	pass
