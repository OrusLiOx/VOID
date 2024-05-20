extends Node2D
@export var ability : int
var cd
var current
var wait = true
var meter
var charges
var chargesLabel
var sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	meter = $ColorRect
	chargesLabel = $Charges
	sprite = $Sprite2D
	$Sprite2D/Sprite2D.texture = load("res://Sprites/Player/ability"+str(ability+1)+".png")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if wait:
		if Globals.player != null:
			wait = false
			cd = Globals.player.a[ability]["cooldown"]
			current = Globals.player.cd[ability]
			charges = Globals.player.charges
	else:
		if current.is_stopped():
			meter.size.y = 0
		else:
			meter.size.y = 100* current.time_left/cd
		if charges[ability] > 0:
			sprite.modulate = Color.WHITE
		else:
			sprite.modulate = Color(.5,.5,.5)
		if Globals.player.a[ability]["charges"]>1:
			chargesLabel.text = str(charges[ability])
		else:
			chargesLabel.text = ""
