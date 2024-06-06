extends Node2D
var laserScene:PackedScene

# Called when the node enters the scene tree for the first time.
func spawn():
	laserScene = load("res://Scenes/Enemies/_Generic/laser.tscn")
	spawn_lasers()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.enemyPause:
		return
	rotate(delta/6)
	pass

func spawn_lasers():
	for i in 4:
		var child = laserScene.instantiate()
		$Lasers.add_child(child)
		child.position = Vector2.ZERO
		child.rotation = i*PI/2	
		child.go(5,5,true)
		$Timer.start(5)


func _on_enemy_base_jammed():
	for child in $Lasers.get_children():
		child.queue_free()
	pass # Replace with function body.


func _on_enemy_base_unjammed():
	spawn_lasers()
	pass # Replace with function body.


func _on_timer_timeout():
	$Timer.stop()
	pass # Replace with function body.
