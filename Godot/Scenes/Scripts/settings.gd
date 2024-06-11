extends Node2D
var LineEditRegEx = RegEx.new()
var lives
var volume = 0

func _ready():
	lives = $Node2D/lives/LineEdit
	LineEditRegEx.compile("^[0-9]*$")
	
func _on_infinite_lives_toggled(toggled_on):
	Globals.infiniteLives = toggled_on
	pass # Replace with function body.


func _on_line_edit_text_changed(new_text):
	if LineEditRegEx.search(new_text):
		Globals.lives = max(1,int(new_text))
	pass # Replace with function body.


func _on_line_edit_focus_exited():
	if !LineEditRegEx.search(lives.text):
		lives.text = str(Globals.lives)
	pass # Replace with function body.


func _on_controls_button_down():
	$Bindings.visible = true
	pass # Replace with function body.
