extends Sprite2D
@export var ability : int
var cd
var current
var wait = true
var meter
var charges
var chargesLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	meter = $ColorRect
	chargesLabel = $Charges
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
			self_modulate = Color.WHITE
		else:
			self_modulate = Color(.5,.5,.5)
		chargesLabel.text = str(charges[ability])
