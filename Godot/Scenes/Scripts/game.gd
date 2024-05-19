extends Node2D
var gameState
var healthSprites:Array

var wave
var waveWait
var waveTimer
var waveTimerBar
var waveTimerCount
var waveLength
var waveWeight
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
	holdEnemies = $holdEnemies
	waveTimer =$WaveTimer
	waveTimerBar = $Hud/Wave/TimeBar/Bar
	waveTimerCount = $Hud/Wave/TimeBar/Bot/Label
	gameState = "inactive"
	
	enemyData = {
		"gattler":
		{
			"scene": load("res://Scenes/Enemies/Hazard/gattling_gunner.tscn"),
			"weight":5,
			"tags": ["corner"]
		},
		"spike bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spike_bomb.tscn"),
			"weight":2,
			"tags": ["hazard"]
		},
		"spinning laser":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spinning_laser.tscn"),
			"weight":5,
			"tags": ["hazard"]
		},
		"wave bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/wave_bomb.tscn"),
			"weight":2,
			"tags": ["hazard"]
		},
		"gunner":
		{
			"scene": load("res://Scenes/Enemies/Mobile/gunner.tscn"),
			"weight":2,
			"tags": []
		},
		"dasher":
		{
			"scene": load("res://Scenes/Enemies/Mobile/dasher.tscn"),
			"weight":2,
			"tags": []
		},
		"spike ball":
		{
			"scene": load("res://Scenes/Enemies/Mobile/spike_ball.tscn"),
			"weight":1,
			"tags": []
		}
	}
	
	generate_health_bar()
	pass # Replace with function body.

func start():
	Globals.player.reset()
	
	lives = Globals.lives
	for child in $holdProjectiles.get_children():
		child.queue_free()
	for child in holdEnemies.get_children():
		child.queue_free()
	wave = 0
	waveLength = 30
	waveWait = 5
	waveWeight = 14
	enemyTypes = 3
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
		for r in 5:
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

func _on_player_update_health(cur, maxhp):
	cur = max(0,cur)
	for i in cur:
		healthSprites[i].get_child(0).visible = true
	for i in range(cur, maxhp):
		healthSprites[i].get_child(0).visible = false
	
	for i in maxhp:
		healthSprites[i].visible = true
	for i in range(maxhp, 10):
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
	$Update.visible = false
	Globals.player.canAbility = false
	Globals.player.inv = true
	Globals.player.continue_cooldowns()
	gameState = "start wave"
	wave += 1
	$Hud/Wave/Label.text = "Wave\n"+str(wave)
	reset_spawns()
	spawn_wave()
	waveTimer.start(waveWait)

func wave_end():
	gameState = "end wave"
	Globals.enemyPause = true
	Globals.player.canAbility = false
	Globals.player.inv = true
	Globals.player.pause_cooldowns()
	for child in $holdProjectiles.get_children():
		child.queue_free()
	for child in holdEnemies.get_children():
		child.queue_free()
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
			start_wave()
	pass # Replace with function body.

func spawn_wave():
	holdEnemies.modulate.a = .6
	var w = waveWeight
	var possibleEnemies = enemyData.keys()
	var enemies:Array = Array()
	
	for i in enemyTypes+int(wave/10):
		var rand = randi_range(0,possibleEnemies.size()-1)
		var enemy = enemyData[possibleEnemies[rand]]
		enemies.push_back(enemy)	

	for enemy in enemies:
		w-=spawn_pack(enemy)
		
	while w > 0:
		w-=spawn_pack(enemies.pick_random())
	pass

func spawn_pack(enemy):
	var weight = 0
	var amount = max(1, (waveWeight+wave)/(enemyTypes+int(wave/10))/enemy["weight"])
	for i in amount:
		var child
		var pos
			
		if enemy["tags"].find("hazard") != -1:
			if hazardSpawns.size() <=0:
				continue
			else:
				var rand = randi_range(0, hazardSpawns.size()-1)
				pos = hazardSpawns[rand]
				hazardSpawns.remove_at(rand)
		elif enemy["tags"].find("corner") != -1:
			if cornerSpawns.size()<=0:
				continue
			else:
				var rand = randi_range(0, cornerSpawns.size()-1)
				pos = cornerSpawns[rand]
				cornerSpawns.remove_at(rand)
		else:
			pos = Vector2(randf_range(124,1920),randf_range(0,1080))
			
		child = enemy["scene"].instantiate()
		holdEnemies.add_child(child)
		child.position = pos
		
		weight += enemy["weight"]

	return weight

func reset_spawns():
	hazardSpawns.clear()
	for x in 5:
		for y in 4:
			hazardSpawns.push_back(Vector2(1796.0/6*(x+1)+124, 1080.0/5*(y+1)))
	
	cornerSpawns = [
		Vector2(174,50),
		Vector2(1870,50),
		Vector2(1870,1030),
		Vector2(174,1030)
	]
