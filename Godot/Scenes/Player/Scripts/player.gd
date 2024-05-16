extends CharacterBody2D

var speed = 300.0
var iframes = 0
var inv = false
var invTimer:Timer
var hp = 5
var hpMax = 5
var healthBar

var a:Dictionary
var charges:Array 
var zone
var cd:Array
@export var holdAbilities:Node

signal update_health(cur, max)

func _ready():
	invTimer = $Invincibility
	zone = load("res://Scenes/Player/zone.tscn")
	a = {
		0:
		{
			"range": 300,
			"duration": 3,
			"cooldown":7,
			"charges":2
		},
		1:
		{
			"range": 300,
			"duration": 0,
			"cooldown":7,
			"effectDuration":3,
			"charges":1
		},
		2:
		{
			"duration": 2,
			"speedup": 1.5,
			"cooldown":10,
			"charges":1
		},
		3:
		{
			"range": 300,
			"duration": 0,
			"cooldown":60,
			"charges":1
		},
	}
	for i in 4:
		var timer = Timer.new()
		$Cooldowns.add_child(timer)
		cd.push_back(timer)
		timer.timeout.connect(cd_timeout.bind(i))
		charges.push_back(a[i]["charges"])
	Globals.player = self
	healthBar = $Health

func _process(delta):
	process_ability_select()
	
	# i frame flicker
	if iframes <=0:
		healthBar.modulate.a = 1
	else:
		iframes -= delta
		if int(iframes*100)%30 < 15:
			healthBar.modulate.a = .6
		else:
			healthBar.modulate.a = .8

func _physics_process(_delta):
	# Move
	velocity = Input.get_vector("Left","Right","Up","Down")*speed 
		
	move_and_slide()

# on take damage stuff
func die():
	print("die")
	pass

func hit(damage):
	if iframes >0:
		return
	hp = max(0, hp-damage) 
	healthBar.size.y = 42*hp/hpMax
	if hp <=0:
		die()
		return
	iframes = 1
	emit_signal("update_health", hp, hpMax)

func _on_area_2d_area_entered(area):
	if area.is_in_group("Projectile"):
		area.queue_free()
	if area.name == "validZone" or iframes>0 or inv:
		return
		
	hit(1)
	pass # Replace with function body.

# ability stuff
func process_ability_select():
	for i in 4:
		if Input.is_action_just_pressed("Ability"+str(i)):
			cast_ability(i)
			
func cast_ability(ability):
	if charges[ability] <= 0:
		return
	charges[ability] -= 1
	if cd[ability].is_stopped():
		cd[ability].start(a[ability]["cooldown"])
	match ability:
		0:
			cast0()
		1:
			cast1()
		2:
			cast2()
		3:
			cast3()

func cd_timeout(ability):
	charges[ability]+=1
	if charges[ability]<a[ability]["charges"]:
		cd[ability].start(a[ability]["cooldown"])
	else:
		cd[ability].stop()

func cast0():
	var cast = zone.instantiate()
	holdAbilities.add_child(cast)
	cast.global_position = global_position
	cast.set_stuff(a[0]["range"], a[0]["duration"], "antiproj")
	pass
	
func cast1():
	var cast = zone.instantiate()
	holdAbilities.add_child(cast)
	cast.global_position = global_position
	cast.set_stuff(a[1]["range"], a[1]["duration"], "jam", a[1]["effectDuration"])
	pass
	
func cast2():
	inv = true
	modulate.a = .6
	speed *= a[2]["speedup"]
	invTimer.stop()
	invTimer.start(a[2]["duration"])
	pass

func _on_invincibility_timeout():
	modulate.a = 1
	speed /= a[2]["speedup"]
	invTimer.stop()
	inv = false
	
	pass # Replace with function body.

func cast3():
	var cast = zone.instantiate()
	holdAbilities.add_child(cast)
	cast.global_position = global_position
	cast.set_stuff(a[3]["range"], a[3]["duration"], "kill")
	pass

