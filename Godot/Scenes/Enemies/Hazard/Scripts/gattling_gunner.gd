extends Node2D
var proj
var rotDest:Array
var dest
var sound

func _ready():
	sound = $AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.enemyPause:
		return
	rotation = move_toward(rotation, rotDest[dest], delta/2)
	if abs(rotation - rotDest[dest]) <.01:
		dest = (dest+1) %2
	pass

func spawn():
	rotDest.clear()
	proj = load("res://Scenes/Enemies/_Generic/projectile.tscn")

	if position.x < 1000:
		rotDest.push_back(0)
	else:
		rotDest.push_back(PI)
	
	if position.y <500:
		rotDest.push_back(PI/2)
	else:
		if position.x < 1000:
			rotDest.push_back(-PI/2)
		else:
			rotDest.push_back(PI/2*3)
	rotation = rotDest[0]
	dest = 1
	$Timer.start(.5)

func _on_timer_timeout():
	if $EnemyBase.is_jammed or Globals.enemyPause:
		return
	sound.play()
	var shot = proj.instantiate()
	Globals.holdProj.add_child(shot)
	shot.position = position
	shot.rotation = rotation
	shot.go()
	pass # Replace with function body.

