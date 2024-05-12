extends Node2D
var dest:Vector2
var dir
var timer
var go = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $Timer
	pick_dest()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if go and global_position.distance_squared_to(dest) > 100:
		var newPos = position + dir*delta
		if newPos.x<10 or newPos.x>1910 or newPos.y<10 or newPos.y>1070:
			go = false
			pick_dest()
		else:
			position +=dir*delta
	else:
		if go:
			go = false
			pick_dest()
	pass

func pick_dest():
	if Globals.player != null:
		dir = global_position.direction_to(Globals.player.global_position)
		dir *= global_position.distance_to(Globals.player.global_position)+200
		dest = dir+global_position
		dir = dir.normalized()*1000
		rotation = dir.angle()
	else:
		dest = Vector2.ZERO
	timer.start(1)


func _on_timer_timeout():
	go = true
	pass # Replace with function body.
