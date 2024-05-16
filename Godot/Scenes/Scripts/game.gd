extends Node2D
var gameState
var healthSprites:Array
var wave
var waveTimer
var waveTimerBar
var waveTimerCount
var waveLength

# Called when the node enters the scene tree for the first time.
func _ready():
	wave = 0
	$Pause.visible = false
	waveTimer =$WaveTimer
	waveTimerBar = $Hud/Wave/TimeBar/Bar
	waveTimerCount = $Hud/Wave/TimeBar/Bot/Label
	waveLength = 10
	
	start_wave()
	generate_health_bar()
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
	gameState = "active wave"
	wave += 1
	$Hud/Wave/Label.text = "Wave\n"+str(wave)
	waveTimer.start(waveLength)


func _on_wave_timer_timeout():
	waveTimer.stop()
	gameState = "wave done"
	start_wave()
	pass # Replace with function body.
