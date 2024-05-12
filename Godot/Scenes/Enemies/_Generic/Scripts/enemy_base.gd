extends Node2D
# -1 = jammed until unjammed, else jammed for jammed seconds
var jams:Dictionary
var jammed = false

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	for i in jams.keys():
		if jams[i] != -1:
			jams[i] -= delta
			if jams[i]<=0:
				remove_jam(i)

func jam(obj, time = -1):
	jammed = true
	jams[obj] = time
	var color = Globals.jammedColor
	color.a = get_parent().modulate.a
	get_parent().modulate = color

func remove_jam(obj):
	jams.erase(obj)
	if jams.size() <= 0:
		unjam()

func unjam():
	jammed = false
	var color = Color.WHITE
	color.a = get_parent().modulate.a
	get_parent().modulate = color

