extends Node2D
var projectile
var timer
var dist
var speed
var fireRate
var sound:AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func spawn():
	projectile = load("res://Scenes/Enemies/_Generic/projectile.tscn")
	timer = $Timer
	sound = $AudioStreamPlayer
	dist = randf_range(400,600)
	speed = randf_range(125,175)
	fireRate = randf_range(1.7,2.7)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.enemyPause:
		return
		
	rotation = global_position.direction_to(Globals.player.global_position).angle()
	if position.distance_to(Globals.player.position) > dist:
		position += global_position.direction_to(Globals.player.global_position)*delta*speed
	if timer.is_stopped():
		timer.start(fireRate)
	pass
	
func fire():
	if $EnemyBase.is_jammed:
		return
	sound.play()
	for i in [-1,0,1]:
		var shot = projectile.instantiate()
		Globals.holdProj.add_child(shot)
		shot.position = position
		shot.rotation = rotation+i*deg_to_rad(30)
		shot.go()


func _on_timer_timeout():
	timer.stop()
	fire()
	pass # Replace with function body.
