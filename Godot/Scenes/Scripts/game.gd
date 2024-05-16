extends Node2D
var gameState
var healthSprites:Array
var wave
var waveTimer
var waveTimerBar
var waveTimerCount
var waveLength
var waveWeight
var enemyData:Dictionary
var hazardData:Dictionary
var hazardSpawns:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.holdProj = $holdProjectiles
	wave = 0
	$Pause.visible = false
	waveTimer =$WaveTimer
	waveTimerBar = $Hud/Wave/TimeBar/Bar
	waveTimerCount = $Hud/Wave/TimeBar/Bot/Label
	waveLength = 10
	waveWeight = 10
	enemyData = {
		"gattler":
		{
			"scene": load("res://Scenes/Enemies/Hazard/gattling_gunner.tscn"),
			"weight":3,
			"hazard":false,
			"max":4
		},
		"spike bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spike_bomb.tscn"),
			"weight":1,
			"hazard":true,
			"max":6
		},
		"spinning laser":
		{
			"scene":load("res://Scenes/Enemies/Hazard/spinning_laser.tscn"),
			"weight":5,
			"hazard":true,
			"max":2
		},
		"wave bomb":
		{
			"scene":load("res://Scenes/Enemies/Hazard/wave_bomb.tscn"),
			"weight":3,
			"hazard":true,
			"max":4
		},
		"gunner":
		{
			"scene": load("res://Scenes/Enemies/Mobile/gunner.tscn"),
			"weight":1,
			"hazard":false,
			"max":6
		},
		"dasher":
		{
			"scene": load("res://Scenes/Enemies/Mobile/dasher.tscn"),
			"weight":1,
			"hazard":false,
			"max":6
		},
		"spike ball":
		{
			"scene": load("res://Scenes/Enemies/Mobile/spike_ball.tscn"),
			"weight":1,
			"hazard":false,
			"max":6
		}
	}
	
	reset_hazard_spawns()
	generate_health_bar()
	
	start_wave()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("Pause"):
		if Engine.time_scale == 0:
			Engine.time_scale = 1
			$Pause.visible = false
		else:
			Engine.time_scale = 0
			$Pause.visible = true
	if gameState != "end wave":
		waveTimerBar.size.y = 216*waveTimer.time_left/waveLength
		var t = int(waveTimer.time_left*10)
		if t%10 == 0:
			t/=10.0
			waveTimerCount.text = str(t) +".0 s"
		else:
			t/=10.0
			waveTimerCount.text = str(t) +" s"
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

func _on_player_update_health(cur, max):
	for i in cur:
		healthSprites[i].get_child(0).visible = true
	for i in range(cur, max):
		healthSprites[i].get_child(0).visible = false
	
	for i in max:
		healthSprites[i].visible = true
	for i in range(max, 10):
		healthSprites[i].visible = false
	pass # Replace with function body.

# wave stuff
func start_wave():
	gameState = "start wave"
	wave += 1
	$Hud/Wave/Label.text = "Wave\n"+str(wave)
	spawn_wave()
	waveTimer.start(5)

func spawn_wave():
	var w = waveWeight
	var possibleEnemies = enemyData.keys()
	
	while w > 0:
		var rand = randi_range(0,possibleEnemies.size()-1)
		var enemy = enemyData[possibleEnemies[rand]]
		possibleEnemies.remove_at(rand)
		
		rand = randi_range(1, enemy["max"])
		for i in rand:
			if w <=0:
				return
			var child = enemy["scene"].instantiate()
			$holdEnemies.add_child(child)
			w -=enemy["weight"]
	pass

func _on_wave_timer_timeout():
	waveTimer.stop()
	match gameState:
		"start wave":
			gameState = "active wave"
			waveTimer.start(waveLength)
		"active wave":
			gameState = "end wave"
			for child in $holdProjectiles.get_children():
				child.queue_free()
			for child in $holdEnemies.get_children():
				child.queue_free()
			waveTimer.start(3)
		"end wave":
			start_wave()
	pass # Replace with function body.

func reset_hazard_spawns():
	hazardSpawns.clear()
	for x in 5:
		for y in 4:
			hazardSpawns.push_back(Vector2(1796/6*x, 1080/5*4))
