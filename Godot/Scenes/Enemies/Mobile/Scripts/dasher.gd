extends Node2D
var dest:Vector2
var dir
var timer
var go = false
var base

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $Timer
	base = $EnemyBase
	$Sprite2D.modulate = Globals.normalColor
	pick_dest()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if go and !base.jammed:
		base.set_collision_layer_value(2, true)
		modulate = Globals.dangerColor
	else:
		base.set_collision_layer_value(2, false)
		if !base.jammed:
			modulate = Globals.normalColor
	if base.jammed:
		dest = global_position
	elif go and global_position.distance_squared_to(dest) > 100:
		var newPos = position + dir*delta
		if newPos.x<10 or newPos.x>1910 or newPos.y<10 or newPos.y>1070:
			go = false
			pick_dest()
		else:
			position +=dir*delta
	elif go:
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
	if !base.jammed:
		timer.start(1)


func _on_timer_timeout():
	timer.stop()
	go = true
	pass # Replace with function body.
