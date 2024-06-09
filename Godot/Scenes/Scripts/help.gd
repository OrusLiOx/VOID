extends Node2D
var menus:Dictionary
var current

# Called when the node enters the scene tree for the first time.
func _ready():
	var list={
		"Basics":$Basics,
		"Health & Damage": $Health_Enemies,
		"Abilities Part 1": $Abilities1,
		"Abilities Part 2": $Abilities2
	}
	var y = 0
	var theme = load("res://Themes/MenuButton.tres")
	var child
	for key in list.keys():
		child = Button.new()
		$Buttons.add_child(child)
		child.size = Vector2(500,150)
		child.position = Vector2(0,y)
		y+=150
		child.text = key
		child.button_down.connect(load_menu.bind(list[key]))
		child.theme = theme
		list[key].visible = false
	
	child = Button.new()
	$Buttons.add_child(child)
	child.size = Vector2(500,150)
	child.position = Vector2(0,y)
	child.text = "Exit"
	child.button_down.connect(exit)
	child.theme = theme
	
	$Abilities1/A1variant.modulate = Globals.dangerColor
	$Abilities1/A2Jam.modulate = Globals.jammedColor
	$Health_Enemies/Colors/red.modulate = Globals.dangerColor
	
	current = $Basics
	$Basics.visible = true
	pass # Replace with function body.

func exit():
	visible = false

func load_menu(menu):
	current.visible = false
	menu.visible = true
	current = menu
