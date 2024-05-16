extends Node2D
var sprite
var outline
var col
var state
var timer
var fireTime
var channelTime
var loop

var minChannel = 1.5

func _ready():
	sprite = $ColorRect
	outline = $ColorRect2
	col = $Area2D/CollisionShape2D
	col.disabled = true
	state = "inactive"
	sprite.modulate.a = 0
	timer = $Timer

func go(cTime=minChannel, fTime=.5, l = true):
	timer.stop()
	loop = l
	fireTime = fTime
	channelTime=max(minChannel,cTime)
	timer.start(channelTime-minChannel)

func channel():
	col.disabled = true
	state = "charge"
	sprite.modulate = Globals.normalColor
	outline.modulate.a = 1
	sprite.size.y = 1
	sprite.position.y = -.5
	outline.size.y = sprite.size.y+2
	outline.position.y = sprite.position.y-1
	timer.start(minChannel)

func disable():
	state = "inactive"
	col.disabled = true
	sprite.modulate.a = 0
	outline.modulate.a = 0
	if loop:
		timer.start(channelTime-minChannel)

func fire():
	state = "fire"
	col.disabled = false
	sprite.modulate = Globals.dangerColor
	sprite.size.y = 30
	sprite.position.y = -15
	outline.size.y = sprite.size.y+2
	outline.position.y = sprite.position.y-1
	timer.start(fireTime)

func _on_timer_timeout():
	timer.stop()
	match state:
		"charge":
			fire()
		"fire":
			disable()
		"inactive":
			channel()
	pass # Replace with function body.
