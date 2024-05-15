extends Node2D
# 
var gameState

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("Pause"):
		if Engine.time_scale == 0:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 0
	pass


func _on_valid_zone_area_exited(area):
	if area.is_in_group("Projectile"):
		area.queue_free()
	pass # Replace with function body.
