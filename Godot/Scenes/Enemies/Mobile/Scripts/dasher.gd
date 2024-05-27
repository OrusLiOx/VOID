extends Node2D
var dest:Vector2
var dir
var timer
var go = false
var base
var waitTime

# Called when the node enters the scene tree for the first time.
func spawn():
	timer = $Timer
	base = $EnemyBase
	$Sprite2D.modulate = Globals.normalColor
	waitTime = randf_range(1,2)
	pick_dest()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.enemyPause:
		return
	if go and !base.is_jammed:
		base.set_collision_layer_value(2, true)
		modulate = Globals.dangerColor
	else:
		base.set_collision_layer_value(2, false)
		if !base.is_jammed:
			modulate = Globals.normalColor
	if base.is_jammed:
		dest = global_position
	elif go and global_position.distance_squared_to(dest) > 100:
		var newPos = position + dir*delta
		if newPos.x<134 or newPos.x>1910 or newPos.y<10 or newPos.y>1070:
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
		dir *= global_position.distance_to(Globals.player.global_position)+randi_range(100,300)
		dest = dir+global_position
		dir = dir.normalized()*1000
		rotation = dir.angle()
	else:
		dest = Vector2.ZERO
	if !base.is_jammed:
		timer.start(waitTime)

func _on_timer_timeout():
	timer.stop()
	go = true
	pass # Replace with function body.
