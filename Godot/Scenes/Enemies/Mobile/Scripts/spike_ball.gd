extends Node2D
var hit
var speed

func _ready():
	hit = $Hurt
	modulate = Globals.dangerColor
	speed = randi_range(70,110)
	pass # Replace with function body.


func _process(delta):
	if Globals.player != null:
		position += global_position.direction_to(Globals.player.global_position)*delta*speed
	pass

func set_jam(jammed):
	$Spikes.visible = !jammed
	hit.set_collision_layer_value(2,!jammed)
	if jammed:	
		modulate = Globals.normalColor
	else:
		modulate = Globals.dangerColor


func _on_enemy_base_unjammed():
	set_jam(false)
	pass # Replace with function body.


func _on_enemy_base_jammed():
	set_jam(true)
	pass # Replace with function body.
