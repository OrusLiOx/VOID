extends Node2D
var gameState
var healthSprites:Array

var wave
var waveWait
var waveTimer
var waveTimerBar
var waveTimerCount
var waveLength
var numOfHazards
var numOfPacks
var enemyTypes

var enemyData:Dictionary
var hazardData:Dictionary
var hazardSpawns:Array
var cornerSpawns:Array
var holdEnemies

var lives

signal gameover()

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.holdProj = $holdProjectiles
	Globals.holdEnemies = $holdEnemies
	holdEnemies = $holdEnemies
	waveTimer =$WaveTimer
	waveTimerBar = $Hud/Wave/TimeBar/Bar
	waveTimerCount = $Hud/Wave/TimeBar/Bot/Label
	gameState = "inactive"
	
	hazardData = {
		"gattler":
		{
			"scene": load("res://Scenes/Enemies/Hazard/gattling_gunner.tscn"),
			"group size" : 1,
			"max":4,
			"corner": true
		},
		"spike bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spike_bomb.tscn"),
			"group size" : 3,
			"max":100,
			"corner": false
		},
		"spinning laser":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spinning_laser.tscn"),
			"group size" : 1,
			"max":3,
			"corner": false
		},
		"wave bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/wave_bomb.tscn"),
			"group size" : 3,
			"max":100,
			"corner": false
		}
	}
	
	enemyData = {
		"gunner":
		{
			"scene": load("res://Scenes/Enemies/Mobile/gunner.tscn"),
			"group size" : 3
		
		},
		"dasher":
		{
			"scene": load("res://Scenes/Enemies/Mobile/dasher.tscn"),
			"group size" : 3
		},
		"spike ball":
		{
			"scene": load("res://Scenes/Enemies/Mobile/spike_ball.tscn"),
			"group size" : 7
		}
	}
	
	generate_health_bar()
	pass # Replace with function body.

func start():
	Globals.player.reset()
	Globals.upgrades = $Upgrades
	$Upgrades.visible = false
	$Upgrades.reset()
	
	lives = Globals.lives
	for child in $holdProjectiles.get_children():
		child.queue_free()
	for child in holdEnemies.get_children():
		child.queue_free()
	wave = 0
	waveLength = 1
	waveWait = 1
	numOfHazards = 0
	numOfPacks = 1
	enemyTypes = 1
	start_wave()

func stop():
	waveTimer.stop()
	gameState = "inactive"
	Globals.enemyPause = true
	Globals.player.canAbility = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if gameState == "inactive":
		return
	if gameState != "end wave":
		if gameState == "start wave":
			waveTimerBar.size.y = 216*waveTimer.time_left/waveWait
		else:
			waveTimerBar.size.y = 216*waveTimer.time_left/waveLength
		var t = int(waveTimer.time_left*10)
		if t%10 == 0:
			t/=10.0
			waveTimerCount.text = str(t) +".0 s"
		else:
			t/=10.0
			waveTimerCount.text = str(t) +" s"
	else:
		waveTimerBar.size.y = .001
		waveTimerCount.text = "-.- s"
	pass

# destroy projectiles that leave the zone
func _on_valid_zone_area_exited(area):
	if area.is_in_group("Projectile"):
		area.queue_free()
	pass # Replace with function body.

# health stuff
func generate_health_bar():
	var border = load("res://Sprites/Player/PlayerBase.png")
	var fill = load("res://Sprites/Player/PlayerFill.png")
	var healthBase = $Hud/Health
	for c in 2:
		for r in 4:
			var child = Sprite2D.new()
			child.texture = border
			var fillChild = Sprite2D.new()
			fillChild.texture = fill
			child.add_child(fillChild)
			fillChild.position = Vector2.ZERO
			if c > 0:
				child.visible = false
			
			healthSprites.push_back(child)
			healthBase.add_child(child)
			child.position = Vector2(c*50,r*-50)
			pass

func _on_player_update_health(cur, maxhp, shield = false):
	$Hud/Health/Shield.visible = shield
	cur = max(0,cur)
	for i in cur:
		healthSprites[i].get_child(0).visible = true
	for i in range(cur, maxhp):
		healthSprites[i].get_child(0).visible = false
	
	for i in maxhp:
		healthSprites[i].visible = true
	for i in range(maxhp, 8):
		healthSprites[i].visible = false
	
	if cur == 0:
		if Globals.infiniteLives:
			wave_end()
			wave-=1
			Globals.player.reset()
			$Update.visible = true
			$Update/Label.text = "Infinite lives remaining"
			return
		lives -= 1
		if lives <= 0:
			waveTimer.stop()
			emit_signal("gameover")
		else:
			wave_end()
			wave-=1
			Globals.player.reset()
			$Update.visible = true
			if lives == 1:
				$Update/Label.text = str(lives)+ " life remaining"
			else:
				$Update/Label.text = str(lives)+ " lives remaining"
	pass # Replace with function body.

# wave stuff
func start_wave():
	print("start")
	$Update.visible = false
	Globals.player.canAbility = false
	Globals.player.inv = true
	Globals.player.continue_cooldowns()
	gameState = "start wave"
	wave += 1
	$Hud/Wave/Label.text = str(wave)
	reset_spawns()
	spawn_wave()
	waveTimer.start(waveWait)

func wave_end():
	gameState = "end wave"
	Globals.enemyPause = true
	Globals.player.canAbility = false
	Globals.player.inv = true
	Globals.player.pause_cooldowns()
	Globals.player.heal(Globals.healEachWave)
	
	for child in $holdProjectiles.get_children():
		child.queue_free()
	for child in holdEnemies.get_children():
		child.queue_free()
	
	numOfPacks+=1
	if numOfPacks >= int(numOfHazards/2)+4:
		numOfPacks = 1
		numOfHazards += 1
	
	waveTimer.start(3)

func wave_go():
	gameState = "active wave"
	holdEnemies.modulate.a =1
	Globals.enemyPause = false
	Globals.player.canAbility = true
	Globals.player.inv = false
	for child in holdEnemies.get_children():
		child.spawn()
	waveTimer.start(waveLength)

func _on_wave_timer_timeout():
	waveTimer.stop()
	match gameState:
		"start wave":
			wave_go()
		"active wave":
			$Update.visible = true
			$Update/Label.text = "Wave Complete"
			wave_end()
		"end wave":
			$Update.visible = false
			$Upgrades.start_upgrade_select()
	pass # Replace with function body.

func spawn_wave():
	holdEnemies.modulate.a = .6
	var possibleEnemies = enemyData.keys()
	var hazards:Array = Array()
	
	var i = 0
	
	while i < numOfHazards:
		var haz = hazardData.keys().pick_random()
		while hazards.find(haz) == -1:
			haz = hazardData.keys().pick_random()
		hazards.push_back(haz)
		haz = hazardData[haz]
		
		var spawned = 0
		
		while i < numOfHazards and spawned < haz["max"]:
			spawn_hazard(haz)
			i += 1
			spawned += 1
	
	for j in numOfPacks:
		spawn_pack(enemyData[enemyData.keys().pick_random()])

	pass

func spawn_hazard(hazard):
	for i in hazard["group size"]:
		var child
		var pos
		
		if hazard["corner"]:
			if cornerSpawns.size()<=0:
				continue
			else:
				var rand = randi_range(0, cornerSpawns.size()-1)
				pos = cornerSpawns[rand]
				cornerSpawns.remove_at(rand)
		else:
			if hazardSpawns.size() <=0:
				continue
			else:
				var rand = randi_range(0, hazardSpawns.size()-1)
				pos = hazardSpawns[rand]
				hazardSpawns.remove_at(rand)
			
		child = hazard["scene"].instantiate()
		holdEnemies.add_child(child)
		child.position = pos
		
	pass
	
func spawn_pack(enemy):
	for i in enemy["group size"]:
		var child
		var pos
			
		pos = Vector2(randf_range(124,1920),randf_range(0,1080))
			
		child = enemy["scene"].instantiate()
		holdEnemies.add_child(child)
		child.position = pos

func reset_spawns():
	hazardSpawns.clear()
	for x in 5:
		for y in 4:
			hazardSpawns.push_back(Vector2(1796.0/5.5*(x+1)+124, 1080.0/4.5*(y+1)))
	
	cornerSpawns = [
		Vector2(174,50),
		Vector2(1870,50),
		Vector2(1870,1030),
		Vector2(174,1030)
	]

func _on_upgrades_done():
	print("\nwave " + str(wave))
	$Upgrades.print_upgrades()
	start_wave()
	pass # Replace with function body.
