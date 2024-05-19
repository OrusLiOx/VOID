extends Node2D
var menus:Dictionary
var current

# Called when the node enters the scene tree for the first time.
func _ready():
	current = $Controls
	var list={
		"Controls" : $Controls,
		"Abilities Part 1": $Abilities1,
		"Abilities Part 2": $Abilities2
	}
	var y = 0
	var theme = load("res://Themes/MenuButton.tres")
	
	for name in list.keys():
		var child = Button.new()
		$Buttons.add_child(child)
		child.size = Vector2(500,150)
		child.position = Vector2(0,y)
		y+=200
		child.text = name
		child.button_down.connect(load_menu.bind(list[name]))
		child.theme = theme
	
	var child = Button.new()
	$Buttons.add_child(child)
	child.size = Vector2(500,150)
	child.position = Vector2(0,y)
	child.text = "Exit"
	child.button_down.connect(exit)
	child.theme = theme
	
	
	$Abilities1/A1variant.modulate = Globals.dangerColor
	$Abilities1/A2Jam.modulate = Globals.jammedColor
	pass # Replace with function body.

func exit():
	visible = false

func load_menu(menu):
	current.visible = false
	menu.visible = true
	current = menu
