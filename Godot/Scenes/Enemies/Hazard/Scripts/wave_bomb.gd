extends Node2D
var wave
var timer
var base
var waves:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	wave = load("res://Scenes/Enemies/_Generic/wave.tscn")
	timer = $Timer
	base = $Base
	modulate.a = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if modulate.a < 1:
		modulate.a += delta
		if modulate.a >=1:
			timer.start(.2)
	base.rotate(delta*PI)
	pass

func spawn_wave():
	var parent = Node2D.new()
	waves.push_back(parent)
	if waves.size() >= 6:
		waves.front().queue_free()
		waves.remove_at(0)
	Globals.holdProj.add_child(parent)
	if $EnemyBase.is_jammed:
		return
	var rot = (base.rotation-(PI/2))*-1
	for i in 4:
		var child = wave.instantiate()
		parent.add_child(child)
		child.rotation = rot+i*PI/2
		child.global_position = global_position
		child.go(150)

func _on_timer_timeout():
	spawn_wave()
	pass # Replace with function body.
