extends Node2D
var flickerRate = .5
var timer
var state = 0
var fill
var timer2 = 0
var hitBox:Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	timer = $Timer
	fill = $Fill
	hitBox = $Explosion/Area2D
	$Explosion.visible = false
	hitBox.set_collision_layer_value(2,false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	match state:
		0: # Spawning
			if modulate.a < 1:
				modulate.a += delta
			else:
				timer.start(flickerRate)
				state = 1
		2: # Flicker
			timer2 += delta
			if timer2 >=1:
				state = 3
				timer.stop()
				explode()
		3: # Explode
			if modulate.a > 0:
				modulate.a -= delta*2
				if modulate.a < .7 and hitBox != null:
					hitBox.queue_free()
	pass

func _on_timer_timeout():
	if flickerRate> .1:
		flickerRate -=.03
	else:
		state = 2
	
	if fill.modulate.a == 1:
		fill.modulate.a = 0
	else:
		fill.modulate.a = 1
	
	timer.start(flickerRate)
	pass # Replace with function body.

func explode():
	if $EnemyBase.jammed:
		queue_free()
		return
	hitBox.set_collision_layer_value(2,true)
	$Base.visible=false
	fill.visible=false
	state = 3
	$Explosion.visible = true
	pass
