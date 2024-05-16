extends Node2D
var spawned
var spikes = 6
var rot
var spawnRot =0
@export var parent:Node
var proj:PackedScene
var timer
var sprite
var canFire

# Called when the node enters the scene tree for the first time.
func _ready():
	rot = 0
	proj = load("res://Scenes/Enemies/_Generic/projectile.tscn")
	spawned = false
	canFire = false
	
	sprite = $Base
	timer = $Timer
	timer.start(.8/spikes)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	for i in spikes:
		var child = proj.instantiate()
		parent.add_child(child)
		child.global_position = global_position
		child.rotation = 2*PI/spikes*i+sprite.rotation
		child.go()
		pass

func _on_timer_timeout():
	timer.stop()
	# spawn spikes
	if !spawned:
		var child = Sprite2D.new()
		child.texture = load("res://Sprites/Enemies/projectile.png")
		sprite.add_child(child)
		child.rotation = spawnRot
		spawnRot += 2*PI/spikes
		if sprite.get_children().size() == spikes:
			spawned = true
			canFire = true
			rot = PI/spikes
		else:
			timer.start(.8/spikes)
	else:
		rot += PI/spikes
		if rot > 2*PI:
			rot -= 2*PI
			sprite.rotation -=2*PI
		canFire = true
		pass
	pass # Replace with function body.
	
