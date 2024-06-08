extends Node2D

var bindings:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	bindings = {
		"Up": [KEY_W, KEY_UP, null, null],
		"Down": [KEY_S, KEY_DOWN, null, null],
		"Left": [KEY_A, KEY_LEFT, null, null],
		"Right": [KEY_D, KEY_RIGHT, null, null],
		"Ability0": [KEY_BRACKETLEFT, KEY_1, MOUSE_BUTTON_LEFT, JOY_BUTTON_A],
		"Ability1": [KEY_BRACKETRIGHT, KEY_2, MOUSE_BUTTON_RIGHT, JOY_BUTTON_B],
		"Ability2": [KEY_SHIFT, KEY_3, null, JOY_BUTTON_X],
		"Ability3": [KEY_SPACE, KEY_4, null, JOY_BUTTON_Y],
		"Item": [KEY_F, KEY_5, null, JOY_BUTTON_RIGHT_SHOULDER],
		"Pause": [KEY_ESCAPE, null, null, JOY_BUTTON_START]
	}
	
	for key in bindings.keys():
		InputMap.add_action(key)
		for i in 4:
			set_binding(key, bindings[key][i], i)
			
	
	pass # Replace with function body.

func set_binding(action, event, index = 0):
	if event == null:
		if index < 4 and index >= 0:
			bindings[action][index] = event
		return false
	var e
	match index:
		0:
			e = InputEventKey.new()
			e.set_physical_keycode(event)
		1:
			e = InputEventKey.new()
			e.set_physical_keycode(event)
		2:
			e = InputEventMouseButton.new()
			e.set_button_index(event)
		3:
			e = InputEventJoypadButton.new()
			e.set_button_index(event)
		_:
			print("invalid index value: " , index)
			return false
	
	bindings[action][index] = event
	InputMap.action_add_event(action, e)
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
