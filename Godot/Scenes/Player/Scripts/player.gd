extends CharacterBody2D

var speed = 300.0
var speedMult = 1
var iframes = 0
var inv = false
var invTimer:Timer
var hp = 5
var hpMax = 5
var healthBar
var canAbility
var shield

var a:Dictionary
var charges:Array
var zone
var cd:Array
@export var holdAbilities:Node

var sound:Dictionary

signal update_health(cur, max)

func _ready():
	sound["Hit"] = $HitSound
	sound["Explosion"] = $Explosion
	sound["Big Explosion"] = $BigExplosion
	sound["Jam"] = $Jam
	sound["Hide"] = $Hide
	invTimer = $Invincibility
	zone = load("res://Scenes/Player/zone.tscn")
	a = {
		0:
		{
			"range": 350,
			"duration": 0,
			"cooldown":7,
			"charges":1
		},
		1:
		{
			"range": 350,
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
			"cooldown":90,
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

func reset():
	position.x = (124+1920)/2.0
	position.y = (0+1080)/2.0
	
	reset_cooldowns()
	
	speed = 300.0
	speedMult = 1
	iframes = 0
	inv = false
	hpMax = 4
	shield = false
	heal()
	healthBar.size.y = 42.0*hp/hpMax
	visible = true

func reset_cooldowns():
	for i in 4:
		charges[i] = a[i]["charges"]
		cd[i].stop()
		cd[i].start(.001)

func heal(amount = hpMax):
	hp = min(hpMax, hp+amount)
	emit_signal("update_health", hp, hpMax, shield)
	healthBar.size.y = 42*hp/hpMax
	
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
	velocity = Input.get_vector("Left","Right","Up","Down")*(speed+Globals.get_upgrade_value("speed"))*speedMult
		
	move_and_slide()

# on take damage stuff
func die():
	inv = true
	visible = false
	pass

func hit(damage):
	if iframes >0:
		return
		
	sound["Hit"].play()
	if shield:
		shield = false
		emit_signal("update_health", hp, hpMax, false)	
		iframes = .5 + Globals.get_upgrade_value("iframes")
		return
	hp = max(0, hp-damage)
	healthBar.size.y = 42*hp/hpMax
	iframes = .5 + Globals.get_upgrade_value("iframes")
	
	if hp <=0:
		die()
	emit_signal("update_health", hp, hpMax)

func gain_shield():
	shield = true
	emit_signal("update_health", hp, hpMax, true)

func _on_area_2d_area_entered(area):
	if area.is_in_group("Projectile"):
		area.queue_free()
	if area.name == "validZone" or iframes>0 or inv or !invTimer.is_stopped():
		return
		
	hit(1)
	pass # Replace with function body.

# ability stuff
func process_ability_select():
	for i in 4:
		if Input.is_action_just_pressed("Ability"+str(i)):
			cast_ability(i)
	if Input.is_action_just_pressed("Item"):
		cast_ability(4)
			
func cast_ability(ability):
	if !canAbility:
		return
	if ability == 4:
		Globals.upgrades.use_item()
		return
	if charges[ability] <= 0:
		return
	charges[ability] -= 1
	if cd[ability].is_stopped():
		cd[ability].start(a[ability]["cooldown"]+Globals.get_upgrade_value("a"+str(ability+1)+" cd"))
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
	if charges[ability]<a[ability]["charges"]:
		charges[ability]+=1
	if charges[ability]<a[ability]["charges"]:
		cd[ability].start(a[ability]["cooldown"])
	else:
		cd[ability].stop()

func cast0():
	var cast = zone.instantiate()
	
	sound["Explosion"].play()
	if Globals.has_upgrade("a1 follow"):
		add_child(cast)
	else:
		holdAbilities.add_child(cast)
	cast.global_position = global_position
	cast.set_stuff(a[0]["range"]+Globals.get_upgrade_value("a1 range"),\
		a[0]["duration"]+Globals.get_upgrade_value("a1 linger")+ Globals.get_upgrade_value("a1 dur"),\
		"antiproj")
	pass
	
func cast1():
	var cast = zone.instantiate()
	sound["Jam"].play()
	if Globals.has_upgrade("a2 follow"):
		add_child(cast)
	else:
		holdAbilities.add_child(cast)
	cast.global_position = global_position
	cast.set_stuff(a[1]["range"]+Globals.get_upgrade_value("a2 range"),\
		a[1]["duration"]+Globals.get_upgrade_value("a2 linger")+Globals.get_upgrade_value("a2 dur"),\
		"jam", a[1]["effectDuration"])
	pass
	
func cast2():
	sound["Hide"].play()
	modulate.a = .6
	speedMult = a[2]["speedup"]+Globals.get_upgrade_value("a3 speedup")
	invTimer.stop()
	invTimer.start(a[2]["duration"]+Globals.get_upgrade_value("a3 dur"))
	pass

func _on_invincibility_timeout():
	modulate.a = 1
	speedMult = 1
	invTimer.stop()
	
	pass # Replace with function body.

func cast3():
	var cast = zone.instantiate()
	holdAbilities.add_child(cast)
	cast.global_position = global_position
	sound["Big Explosion"].play()
	cast.set_stuff(a[3]["range"]+Globals.get_upgrade_value("a4 range"), a[3]["duration"]+Globals.get_upgrade_value("a4 dur"), "kill")
	pass

func pause_cooldowns():
	for timer in cd:
		timer.set_paused(true)
		
func continue_cooldowns():
	for timer in cd:
		timer.set_paused(false)
