extends Node2D
var jammed = false

func _ready():
	pass # Replace with function body.


func _process(delta):
	if jammed != $EnemyBase.jammed:
		$Spikes.visible = jammed
		$Hurt.set_collision_layer_value(2, jammed)
		jammed = !jammed
	
	if Globals.player != null:
		position += global_position.direction_to(Globals.player.global_position)*delta*100
	pass
