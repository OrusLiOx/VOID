extends Node2D
var projectile
var timer
@export var parent: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	projectile = load("res://Scenes/Enemies/_Generic/projectile.tscn")
	timer = $Timer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = global_position.direction_to(Globals.player.global_position).angle()
	if position.distance_to(Globals.player.position) > 500:
		position += global_position.direction_to(Globals.player.global_position)*delta*150
	if timer.is_stopped():
		timer.start(2)
	pass
	
func fire():
	if $EnemyBase.is_jammed:
		return
	for i in [-1,0,1]:
		var shot = projectile.instantiate()
		get_parent().add_child(shot)
		shot.position = position
		shot.rotation = rotation+i*deg_to_rad(30)
		shot.go()


func _on_timer_timeout():
	timer.stop()
	fire()
	pass # Replace with function body.
