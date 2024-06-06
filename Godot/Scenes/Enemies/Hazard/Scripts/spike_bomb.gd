extends Node2D
var spikes = 6
var rot
var startRot
var proj:PackedScene
var timer
var sprite
var canFire
var sound : AudioStreamPlayer

func spawn():
	startRot = randf_range(0,PI/spikes)
	rot = 0
	proj = load("res://Scenes/Enemies/_Generic/projectile.tscn")
	canFire = false
	
	sprite = $Sprite2D
	timer = $Timer
	sound = $AudioStreamPlayer
	timer.start(.8/spikes)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.enemyPause:
		return
	var newRot = sprite.rotation+delta*PI/2
	if newRot < rot:
		sprite.rotation = newRot
	elif canFire:
		sprite.rotation = rot
		launch_wave()
		canFire = false
		timer.start(2)
	pass

func launch_wave():
	if $EnemyBase.is_jammed:
		return
	
	sound.play()
	for i in spikes:
		var child = proj.instantiate()
		Globals.holdProj.add_child(child)
		child.global_position = global_position
		child.rotation = 2*PI/spikes*i+sprite.rotation
		child.go()
		pass

func _on_timer_timeout():
	timer.stop()
	rot += PI/spikes
	if rot > 2*PI:
		rot -= 2*PI
		sprite.rotation -=2*PI
	canFire = true
	
