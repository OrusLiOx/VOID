extends Node
var jammedColor
var dangerColor
var normalColor
var player

func _ready():
	set_color_type("color")

func set_color_type(type):
	match type:
		"jam":
			jammedColor = Color("abdaff")
			dangerColor = Color("ffffff")
			normalColor = Color("ffffff")
		"color":
			jammedColor = Color("abdaff")
			dangerColor = Color("ff5f5f")
			normalColor = Color("ffffff")
		"none":
			jammedColor = Color("ffffff")
			dangerColor = Color("ffffff")
			normalColor = Color("ffffff")
		_:
			jammedColor = Color("aeaeae")
			dangerColor = Color("ffffff")
			normalColor = Color("ffffff")

func add_colors(c1,c2, weight =.5):
	var color:Color
	color.r = c1.r*weight + c2.r*(1-weight)
	color.g = c1.g*weight + c2.g*(1-weight)
	color.b = c1.b*weight + c2.b*(1-weight)
	color.a = c1.a*weight + c2.a*(1-weight)
	return color
	
