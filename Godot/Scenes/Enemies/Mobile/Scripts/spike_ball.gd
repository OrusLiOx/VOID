extends Node2D
var jammed = false
var hit

func _ready():
	hit = $Hurt
	modulate = Globals.dangerColor
	pass # Replace with function body.


func _process(delta):
	if jammed != $EnemyBase.jammed:
		$Spikes.visible = jammed
		hit.set_collision_layer_value(2, jammed)
		jammed = !jammed
		if !jammed:	
			modulate = Globals.dangerColor
	
	if Globals.player != null:
		position += global_position.direction_to(Globals.player.global_position)*delta*100
	pass
