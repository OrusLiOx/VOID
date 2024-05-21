extends Node2D

var available: Array
var have : Dictionary
var temp : Dictionary
var item : String
var itemUses : int

func reset():
	temp.clear()
	have.clear()
	available.clear()
	
	item = ""
	itemUses = 0
	
	have["temp dur"] = 1
	have["item uses"] = 1
	
	available.push_back("a4 charge")
	
	available.push_back("a1 linger")
	available.push_back("a2 linger")

	available.push_back("a3 proj")
	available.push_back("a3 jam")
	
	for i in 5:
		available.push_back("a1 cd")
		available.push_back("a2 cd")
		available.push_back("a3 cd")
		available.push_back("a4 cd")
		
		available.push_back("a1 range")
		available.push_back("a2 range")
		available.push_back("a4 range")
		
		available.push_back("a3 dur")
		available.push_back("a3 speedup")
		
		available.push_back("speed")
		available.push_back("iframes")
		available.push_back("item uses")
		available.push_back("temp dur")
		available.push_back("health")
	
	available.push_back("heal")
	available.push_back("item proj")
	available.push_back("item jam")
	available.push_back("item cd")
	available.push_back("item heal")
	
	available.push_back("temp pick 3")
	available.push_back("temp shield")
	available.push_back("temp short wave")
	available.push_back("temp range")
	available.push_back("temp dur")
	available.push_back("temp cd")
	

func pick_rand(num = 3):
	var arr:Array = []
	
	while arr.size()<num:
		var pick = available.pick_random()
		if arr.find(pick) == -1:
			arr.push_back(pick)
	
	return arr

func set_upgrade_display(obj, upgrade):
	var title
	var desc
	
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
					var s =.5
					if i ==4:
						s = 5
					var quantity = have[upgrade]
					title += "Reduce Cooldown +" +str(quantity+1)
					
					desc = "Reduce the cooldown of Ability "+str(i)+" by "+str(s)+"s\n\n"
					quantity = str(Globals.player.a[i]["cooldown"]-(quantity*s))
					desc+="Current: " + str(quantity) + "s\n"
					desc +="New: "+str(quantity-s)+"s"
				elif upgrade.contains("range"):
					var quantity = have[upgrade]
					title += "Range +" +str(quantity+1)
					
					desc = "Increase the range of Ability "+str(i)+" by 50 units\n\n"
					quantity = str(Globals.player.a[i]["range"]+(quantity*50))
					desc+="Current: " + str(quantity) + "s\n"
					desc +="New: "+str(quantity+50)+"s"
				elif upgrade.contains("dur"):
					var quantity = have[upgrade]
					title += "Duration +" +str(quantity+1)
					
					desc = "Increase the duration of Ability "+str(i)+" by .5s\n\n"
					quantity = str(Globals.player.a[i]["range"]+(quantity*50))
					desc+="Current: " + str(quantity) + "s\n"
					desc +="New: "+str(quantity+50)+"s"
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
			var quantity = have["speed"]
			title = "Speed Boost +" + str(quantity+1)
			desc = "Increase speed boost gained from Ability 3 by .2\n\n"
			quantity = 1.5 + quantity*.2
			desc+= "Current: x" + str(quantity) +"\n"
			desc+= "New: x" + str(quantity + .2)
		
		"speed":
			var quantity = have["speed"]
			title = "Speed +" + str(quantity+1)
			desc = "Increase base speed by 50\n\n"
			quantity =Globals.player.speed + quantity*50
			desc+= "Current: " + str(quantity) +"\n"
			desc+= "New: " + str(quantity + 50)
		"iframes":
			var quantity = have["iframes"]
			title = "Invincibility Frames +" + str(quantity+1)
			desc = "Increases how long you are invincible after getting hit by .25s\n\n"
			quantity =Globals.player.speed + quantity*.25
			desc+= "Current: " + str(quantity) +"s\n"
			desc+= "New: " + str(quantity + .25)+"s"
		"item uses":
			var quantity = have["item uses"]
			title = "Item Uses  +" + str(quantity+1)
			desc = "Increase how mnay times you can use items by 1\n\n"
			quantity = Globals.player.speed + quantity*50
			desc+= "Current: " + str(quantity) +"\n"
			desc+= "New: " + str(quantity + 50)
		"temp dur":
			var quantity = have["temp dur"]
			title = "Temporary Effect Duration  +" + str(quantity+1)
			desc = "Increases how many waves temporary effects last for by 1\n\n"
			quantity =Globals.player.speed + quantity
			desc+= "Current: " + str(quantity) +" waves\n"
			desc+= "New: " + str(quantity + 1) + " waves"
		"health":
			var quantity = have["health"]
			title = "Health  +" + str(quantity+1)
			desc = "Increases maximum health by 1\n\n"
			quantity = 5 + quantity
			desc+= "Current: " + str(quantity) +"\n"
			desc+= "New: " + str(quantity + 1)
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
			title += "Jam"
			desc = "Heals 3 health on use\n\n"
		
		"temp pick 3":
			title+="Pick 3 Next Wave"
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
		desc += "This perk will last for " + str(have["temp dur"]) + " waves\n\n"
		
	elif upgrade.contains("item") and upgrade != "item uses":
		desc += "This item can be used " + str(have["item uses"]) + " times\n\n"
		if item != "":
			desc +="This will replace your current item\n"
			desc+="Current Item: " + item
			desc+="\nUses Left: " + str(itemUses)
	
	for child in obj.get_children():
		if child.name == "Name":
			child.text = title
		elif child.name == "Description":
			child.text = desc

func take_perk(upgrade):
	if upgrade.contains("temp") and upgrade != "temp dur":
		if temp.keys().find(upgrade) != -1:
			temp[upgrade] += have["temp dur"]
		else:
			temp[upgrade] = have["temp dur"]
	
	elif upgrade.contains("item") and upgrade != "item uses":
		item = upgrade
		itemUses = have["item uses"]
	else:
		if temp.keys().find(upgrade) != -1:
			have[upgrade] += 1
		else:
			have[upgrade] = 1
