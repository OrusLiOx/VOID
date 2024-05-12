extends Node2D
var spawned
var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	spawned = false
	modulate.a = 0
	var proj:PackedScene = load("res://Scenes/Enemies/projectile.tscn")
	var spikes = 6
	parent = $Spikes
	for i in spikes:
		var child = proj.instantiate()
		parent.add_child(child)
		child.position = Vector2(0,0)
		child.rotation = 2*PI/spikes*i
		
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if modulate.a < 1:
		modulate.a += delta
	else:
		if !spawned:
			$Timer.start(.5)
			spawned = true
		
	if parent.get_children().size() == 0:
		queue_free()
	pass


func _on_timer_timeout():
	if $EnemyBase.jammed:
		queue_free()
		return
	for child in parent.get_children():
		child.go()
	pass # Replace with function body.
	
