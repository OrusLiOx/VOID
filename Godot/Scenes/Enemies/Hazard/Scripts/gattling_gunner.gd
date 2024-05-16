extends Node2D
var proj
var rotDest:Array
var dest

# Called when the node enters the scene tree for the first time.
func _ready():
	proj = load("res://Scenes/Enemies/_Generic/projectile.tscn")
	spawn(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = move_toward(rotation, rotDest[dest], delta/2)
	if abs(rotation - rotDest[dest]) <.01:
		dest = (dest+1) %2
	pass

func spawn(dir):
	rotDest.clear()
	match dir:
		0:
			position = Vector2(174,50)
		1:
			position = Vector2(1870,50)
		2:
			position = Vector2(1870,1030)
		3:
			position = Vector2(174,1030)
	
	rotDest.push_back(0+PI/2*dir)
	rotDest.push_back(PI/2+PI/2*dir)
	rotation = rotDest[0]
	dest = 1
	$Timer.start(.5)


func _on_timer_timeout():
	if $EnemyBase.is_jammed:
		return
	var shot = proj.instantiate()
	Globals.holdProj.add_child(shot)
	shot.position = position
	shot.rotation = rotation
	shot.go()
	pass # Replace with function body.

