extends Node2D
var gameActive 
var gameScene
var pauseScene
var gameoverScene
var queueUnpause = -1
var queueStartGame = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	gameoverScene = $GameOver
	gameScene = $Game
	pauseScene = $Pause
	gameoverScene.visible = false
	pauseScene.visible = false
	to_title()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if queueUnpause == 0:
		queueUnpause = 1
	elif queueUnpause == 1:
		unpause()
	if queueStartGame == 0:
		queueStartGame = 1
	elif queueStartGame == 1:
		start_game()
		
	if Input.is_action_just_pressed("Pause"):
		if gameActive:
			if Engine.time_scale == 0:
				unpause()
			else:
				pause()
		elif $Settings.visible:
			close_settings()
	pass

func start_game():
	if queueStartGame == -1:
		queueStartGame = 0
	elif queueStartGame == 1:
		queueStartGame = -1
		$Title.visible = false
		gameActive = true
		gameScene.visible = true
		gameScene.start()

func end_game():
	gameoverScene.visible = false
	unpause()
	gameActive = false
	gameScene.visible = false
	gameScene.end_game()
	Globals.player.position.y = 2000
	Globals.player.canAbility = false

func to_title():
	end_game()
	Globals.player.canAbility = false
	pauseScene.visible = false
	gameoverScene.visible = false
	$Title.visible = true
	$Settings.visible = false
	$Help.visible = false

func restart_game():
	end_game()
	start_game()

func pause():
	if gameoverScene.visible:
		return
	queueUnpause = -1
	Engine.time_scale = 0
	Globals.player.canAbility = false
	$Pause.visible = true

func unpause():
	$Settings.visible = false
	$Help.visible = false
	queueUnpause = -1
	Engine.time_scale = 1
	Globals.player.canAbility = true
	pauseScene.visible = false

func open_settings():
	$Settings.visible = true

func close_settings():
	if $Settings/Bindings.visible:
		$Settings/Bindings.visible = false
	else:
		$Settings.visible = false

func open_help():
	$Help.visible = true

func button_down(type):
	match type:
		"start" : 
			start_game()
		"restart":
			restart_game()
		"settings":
			open_settings()
		"help":
			open_help()
		"exit":
			end_game()
		"continue":
			unpause()

func _on_game_gameover():
	gameoverScene.visible = true
	Globals.player.canAbility = false
	var waves = gameScene.wave-1
	if waves != 1:
		waves = str(waves) + " waves"
	else:
		waves = str(waves)+" wave"
	gameoverScene.get_child(0).text = "You survived\n" + waves
		
	pass # Replace with function body.
