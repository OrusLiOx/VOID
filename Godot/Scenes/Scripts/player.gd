extends CharacterBody2D

var speed = 300.0
var iframes = 0
var hp = 100
var healthBar
var ability

func _ready():
	Globals.player = self
	healthBar = $Health
	ability = 0

func _physics_process(delta):
	for i in 4:
		if Input.is_action_just_pressed("Ability"+str(i)):
			ability = i
	if Input.is_action_just_pressed("AbilityDown"):
		ability += 1
		ability %= 4
	if Input.is_action_just_pressed("AbilityUp"):
		ability += 3
		ability %= 4
	if Input.is_action_just_pressed("Cast"):
		cast_ability()
	# Move
	velocity = Input.get_vector("Left","Right","Up","Down")*speed 
		
	move_and_slide()
	
	# i frame flicker
	if iframes <=0:
		healthBar.modulate.a = 1
	else:
		iframes -= delta
		if int(iframes*100)%30 < 15:
			healthBar.modulate.a = .6
		else:
			healthBar.modulate.a = .8

func die():
	print("die")
	pass

func hit(damage):
	if iframes >0:
		return
	hp = max(0, hp-damage) 
	healthBar.size.y = 42*hp/100
	if hp <=0:
		die()
		return
	iframes = 1

func _on_area_2d_area_entered(area):
	if area.name == "validZone" or iframes>0:
		return
	hit(25)
	if area.is_in_group("Projectile"):
		area.queue_free()
	pass # Replace with function body.

func cast_ability():
	print(ability)
