extends Node2D
# -1 = jammed until unjammed, else jammed for jammed seconds
var jams:Dictionary
var is_jammed = false
signal jammed()
signal unjammed()

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	for i in jams.keys():
		if jams[i] != -1:
			jams[i] -= delta
			if jams[i]<=0:
				remove_jam(i)

func jam(obj, time = -1):
	if is_jammed == false:
		emit_signal("jammed")
	is_jammed = true
	jams[obj] = time
	var color = Globals.jammedColor
	color.a = get_parent().modulate.a
	get_parent().modulate = color

func remove_jam(obj):
	jams.erase(obj)
	if jams.size() <= 0:
		unjam()

func unjam():
	var change = false
	if is_jammed == true:
		change = true
	is_jammed = false
	var color = Globals.normalColor
	color.a = get_parent().modulate.a
	get_parent().modulate = color
	if change:
		emit_signal("unjammed")

