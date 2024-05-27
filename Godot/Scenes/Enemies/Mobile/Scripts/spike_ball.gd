extends Node2D
var hit
var speed
var targetOffset

func spawn():
	hit = $Hurt
	modulate = Globals.dangerColor
	speed = randf_range(10,150)
	targetOffset = Vector2(randf_range(-50,50),randf_range(-50,50))
	pass # Replace with function body.


func _process(delta):
	if Globals.enemyPause:
		return
	if Globals.player != null:
		position += global_position.direction_to(Globals.player.global_position+targetOffset)*delta*speed
	pass

func set_jam(jammed):
	$Spikes.visible = !jammed
	hit.set_collision_layer_value(2,!jammed)
	if !jammed:
		modulate = Globals.dangerColor


func _on_enemy_base_unjammed():
	set_jam(false)
	pass # Replace with function body.


func _on_enemy_base_jammed():
	set_jam(true)
	pass # Replace with function body.
