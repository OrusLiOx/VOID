extends Area2D
func set_border(color):
	$Sprite2D.modulate = color
func set_fill(color):
	$Sprite2D2.modulate = color

func set_size(s):
	set_size_help($Sprite2D, s)
	set_size_help($Sprite2D2, s)
	$CollisionShape2D.shape.radius = 150* s/300.0
	pass

func set_size_help(obj, s):
	obj.scale.x = s/300.0
	obj.scale.y = s/300.0
	
