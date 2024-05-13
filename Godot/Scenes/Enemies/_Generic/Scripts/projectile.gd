extends Area2D
var moving = false
var speed = 500

func go(s = 500):
	speed = s
	moving = true
	modulate = Globals.dangerColor
	
func _process(delta):
	if moving:
		position += Vector2.from_angle(rotation)*speed*delta
	pass
