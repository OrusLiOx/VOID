extends Node2D
@export var itemDisplay:Node2D

var available: Array
var have : Dictionary
var temp : Dictionary
var item : String
var itemUses : int
var choices:Array
var choicesButtons:Node2D
var choiceLabel:Label
var take
var scaling : Dictionary

var baseItemUses
var baseTempDur

signal done()

# SETUP
func _ready():
	choicesButtons = $UpgradeChoiceDisplay/Buttons
	choiceLabel = $UpgradeChoiceDisplay/Label2
	var i = 0
	for child in choicesButtons.get_children():
		child.button_down.connect(take_upgrade.bind(i))
		i+=1
	
	baseItemUses = {
		"heal":1,
		"jam":3,
		"proj":3,
		"cd":3
	}
	baseTempDur = {
		"temp shield": 3,
		"temp short wave": 3,
		"temp range": 3,
		"temp dur": 3,
		"temp cd": 3
	}
	
	scaling["iframes"] = .25
	scaling["speed"] = 50
	scaling["a3 speedup"] = .2
	
	scaling["a1 dur"] = .5
	scaling["a2 dur"] = .5
	scaling["a3 dur"] = .5
	scaling["a4 dur"] = .5
	
	scaling["a1 range"] = 50
	scaling["a2 range"] = 50
	scaling["a4 range"] = 50

	scaling["a1 cd"] = -.5
	scaling["a2 cd"] = -.5
	scaling["a3 cd"] = -.5
	scaling["a4 cd"] = -5

func reset():
	itemDisplay.modulate = Color(.5,.5,.5)
	itemDisplay.get_child(0).modulate.a = 0
	itemDisplay.get_child(1).text = ""
	item = ""
	
	temp.clear()
	have.clear()
	available.clear()
	
	#reset_general()
	#reset_abilities()
	#reset_items()
	reset_temps()

func reset_general():
	have["health"] = 0
	have["iframes"] = 0
	have["speed"] = 0
	
	available.push_back("pick 3")
	available.push_back("heal")
	
	available.push_back("health")
	
	available.push_back("speed")
	available.push_back("iframes")

func reset_abilities():
	have["a4 charge"] = 1
	
	have["a1 cd"] = 0
	have["a2 cd"] = 0
	have["a3 cd"] = 0
	have["a4 cd"] = 0
	
	
	have["a1 range"] = 0
	have["a2 range"] = 0
	have["a4 range"] = 0
	
	have["a3 dur"] = 0
	have["a3 speedup"] = 0
	
	#available.push_back("a4 charge")
	
	#available.push_back("a1 linger")
	#available.push_back("a2 linger")
#
	#available.push_back("a3 proj")
	#available.push_back("a3 jam")
	
	available.push_back("a1 cd")
	available.push_back("a2 cd")
	available.push_back("a3 cd")
	available.push_back("a4 cd")
		
	available.push_back("a1 range")
	available.push_back("a2 range")
	available.push_back("a4 range")
		
	available.push_back("a3 dur")
	available.push_back("a3 speedup")
	
func reset_items():
	item = ""
	itemUses = 0
	have["item uses"] = 0
	available.push_back("item proj")
	available.push_back("item jam")
	available.push_back("item cd")
	available.push_back("item heal")
	
	available.push_back("item uses")

func reset_temps():
	have["temp dur"] = 0
	available.push_back("temp shield")
	available.push_back("temp short wave")
	available.push_back("temp range")
	available.push_back("temp dur")
	available.push_back("temp cd")
	
	available.push_back("temp dur")

# UPGRADE SELECTION
# call at the end of waves to start upgrade selection
func start_upgrade_select():
	visible = true
	take = 1
	if have.has("pick 3"):
		take = 3
		have.erase("pick 3")
	
	upgrade_select()

# creates selection for one round of upgrade choices
func upgrade_select():
	if take == 0:
		visible = false
		emit_signal("done")
		return
		
	if take>1:
		choiceLabel.visible = true
	else:
		choiceLabel.visible = false
		
	choices = pick_rand()
	var children = choicesButtons.get_children()
	for j in 3:
		set_upgrade_display(children[j], choices[j])

# returns array of num unique upgrades
func pick_rand(num = 3):
	var arr:Array = []
	while arr.size()<num:
		var pick = available.pick_random()
		if arr.find(pick) == -1:
			arr.push_back(pick)
	
	return arr

# sets given upgrade display to given upgrade info
func set_upgrade_display(obj, upgrade):
	var title:String
	var desc:String
	
	if upgrade.contains("temp") and upgrade != "temp dur":
		title = "Temporary:\n"
	elif upgrade.contains("item") and upgrade != "item uses":
		title = "Item:\n"
	else:
		for i in range(1,5):
			if upgrade.contains("a"+str(i)):
				title = "Ability "+str(i)+":\n"
				if upgrade.contains("linger"):
					title+="Persist"
					desc = "Ability "+ str(i)+ " will persist in the spot you cast it for 1 second"
				elif upgrade.contains("cd"):
					title += "Reduce Cooldown +" +str(have[upgrade]+1)
					desc = get_scaling_upgrade_desc(upgrade, Globals.player.a[i-1]["cooldown"], "Reduce the cooldown of Ability "+str(i)+" by ","s")
				elif upgrade.contains("range"):
					title += "Range +" +str(have[upgrade]+1)
					desc = get_scaling_upgrade_desc(upgrade, Globals.player.a[i-1]["range"], "Increase the range of Ability "+str(i)+" by "," units")
				elif upgrade.contains("dur"):
					title += "Duration +" +str(have[upgrade]+1)
					desc = get_scaling_upgrade_desc(upgrade, Globals.player.a[i-1]["duration"], "Increase the duration of Ability "+str(i)+" by ","s")
				break
			
	match upgrade:
		"a4 charge":
			title += "Extra Charge"
			desc = "Allows you to have 2 charges of Ability 4 stored at a time"

		"a3 proj":
			title += "Anti-Projectile"
			desc = "When the effect of Ability 3 ends, projectiles within 300 units of you will be destroyed"
		"a3 jam":
			title += "Jam"
			desc = "When the effect of Ability 3 ends, enemies within 300 units of you will be jammed for 3 seconds"

		"a3 speedup":
			title += "Speed Boost +" + str(have["speed"]+1)
			desc = get_scaling_upgrade_desc(upgrade, Globals.player.a[2]["speedup"], "Increase speed boost gained from Ability 3 by ","")
		
		"speed":
			title = "Speed +" + str(have["speed"]+1)
			desc = get_scaling_upgrade_desc(upgrade, Globals.player.speed, "Increase base movement speed by ","")
		"iframes":
			title = "Invincibility Frames +" + str(have["iframes"]+1)
			desc = get_scaling_upgrade_desc(upgrade, .5, "Increases how long you are invincible after getting hit by ","s")
		"item uses":
			title = "Item Uses +" + str(have["item uses"]+1)
			desc = get_scaling_upgrade_desc(upgrade, 0, "Increase how many times you can use items by ","")
		"temp dur":
			title = "Temporary Effect Duration  +" + str(have["temp dur"]+1)
			desc = get_scaling_upgrade_desc(upgrade, 0, "Increases the duration of temporary effects by "," wave")
		"health":
			title = "Health +" + str(have["health"]+1)
			desc = get_scaling_upgrade_desc(upgrade, 5, "Increases maximum health by ","")
		"heal":
			title = "Heal"
			desc = "Heal to full health"
			
		"item proj":
			title += "Anti-Projectile"
			desc = "Destroys all projectiles on use\n\n"
		"item jam":
			title += "Jam"
			desc = "Jams all enemies for 3 seconds on use\n\n"
		"item cd":
			title += "Ability Refresh"
			desc = "Resets cooldown on all abilities upon use\n\n"
		"item heal":
			title += "Heal"
			desc = "Heals 3 health on use\n\n"
		
		"pick 3":
			title += "Pick 3 Next Wave"
			desc = "At the end of the next wave, you get 3 perks instead of 1\n\n"
		"temp shield":
			title+="Shield"
			desc = "At the start of the wave, you gain a shield that will block 1 hit\n\n"
		"temp short wave":
			title+= "Shorter Wave"
			desc += "The next wave will last for 20s instead of 30s\n\n"
		"temp range":
			title+="Ability Range"
			desc = "Range of Abilities 1, 2 and 4 are increased by 100 units\n\n"
		"temp cd":
			title+="Ability Range"
			desc = "Reduces the cooldown of all abilities by 1s\n\n"
			
	if upgrade.contains("temp") and upgrade != "temp dur":
		desc += "This perk will last for " + str(baseTempDur[upgrade] +have["temp dur"]) + " waves\n\n"
		
	elif upgrade.contains("item") and upgrade != "item uses":
		desc += "This item can be used " + str(baseItemUses[upgrade.substr(5)]+have["item uses"]) + " times\n\n"
		if item != "":
			desc +="This will replace your current item\n"
	
	for child in obj.get_children():
		if child.name == "Name":
			child.text = title
		elif child.name == "Description":
			child.text = desc

# generates description for upgrades which scale based on how many times it was picked up
func get_scaling_upgrade_desc(upgrade, baseValue = 0.0, startText ="", unit = ""):
	var s
	if scaling.has(upgrade):
		s = scaling[upgrade]
	else:
		s = 1
		
	var desc = ""
	var quantity = baseValue + s*have[upgrade]
	
	if startText !="":
		desc = startText + str(abs(s)) + unit 
	desc+= "\n\n"
	
	if upgrade == "a3 speedup":
		desc += "Current: x" + str(quantity) + unit+"\n"
		desc += "New: x" + str(quantity+s) + unit
	elif upgrade == "item uses" :
		desc += "Current: +" + str(quantity) + unit+"\n"
		desc += "New: +" + str(quantity+s) + unit
	elif upgrade == "temp dur":
		if quantity == 1:
			desc += "Current: +" + str(quantity) + unit+"\n"
		else:
			desc += "Current: +" + str(quantity) + unit+"s\n"
		desc += "New: +" + str(quantity+s) + unit+"s"
	else:
		desc += "Current: " + str(quantity) + unit+"\n"
		desc += "New: " + str(quantity+s) + unit
	
	return desc

# modifies nessecary values upon selecting an upgrade
func take_upgrade(upgrade):
	take -=1
	upgrade = choices[upgrade]
	match upgrade:
		"heal":
			Globals.player.heal()
		"health":
			Globals.player.hpMax +=1
			Globals.player.heal(1)
			if Globals.player.hpMax == 8:
				available.remove_at(available.find(upgrade))
		_:
			if upgrade.find("temp")!=-1 and upgrade != "temp dur":
				temp[upgrade] = baseTempDur[upgrade]+have["temp dur"]
			elif upgrade.find("item")!=-1 and upgrade != "item uses":
				item = upgrade.substr(5)
				itemUses = baseItemUses[item]+ have["item uses"]
				itemDisplay.modulate = Color.WHITE
				itemDisplay.get_child(1).text = str(itemUses)
				itemDisplay.get_child(0).modulate.a =1
				match item:
					"heal":
						itemDisplay.get_child(0).texture = load("res://Sprites/Player/PlayerFill.png")
					"proj":
						itemDisplay.get_child(0).texture = load("res://Sprites/Player/ability1.png")
					"jam":
						itemDisplay.get_child(0).texture = load("res://Sprites/Player/ability2.png")
					"cd":
						itemDisplay.get_child(0).texture = load("res://Sprites/Player/cooldown.png")
				
			else:
				if have.has(upgrade):
					have[upgrade] += 1
				else:
					have[upgrade] = 1
				if upgrade == "item uses" and item !="":
					itemUses += 1 
					itemDisplay.get_child(1).text = str(itemUses)
	
	upgrade_select()

# USE ITEM
func use_item():
	itemUses -= 1
	itemDisplay.get_child(1).text = str(itemUses)
	
	match item:
		"heal":
			Globals.player.heal(3)
		"proj":
			for child in Globals.holdProj.get_children():
				if child.is_in_group("Projectile"):
					child.queue_free()
				else:
					for c in child.get_children():
						c.queue_free()
		"jam":
			for child in Globals.holdEnemies.get_children():
				for obj in child.get_children():
					if obj.is_in_group("Jammable"):
						obj.jam(self, 3)
		"cd":
			Globals.player.reset_cooldowns()
	
	if itemUses <= 0:
		itemDisplay.modulate = Color(.5,.5,.5)
		itemDisplay.get_child(0).modulate.a = 0
		itemDisplay.get_child(1).text = ""
		item = ""

# MISC
func print_upgrades():
	print("{")
	print("\titem: " + item)
	print("\titem uses left: " , itemUses)
	for key in have.keys():
		print("\t" + key + ": " + str(have[key]))
	print()
	for key in temp.keys():
		print("\t" + key + ": " + str(temp[key]))
	print("}")

func get_value(upgrade):
	if have.has(upgrade):
		return have[upgrade]*scaling[upgrade]
	return 0
