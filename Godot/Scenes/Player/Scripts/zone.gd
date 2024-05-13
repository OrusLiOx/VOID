extends Node2D
var effectTime
var effect

func set_stuff(size, time, e, eTime = 0):
	$Circle.set_size(size)
	effect = e
	effectTime = eTime
	match e:
		"jam":
			var color = Globals.jammedColor
			color.a = .3
			$Circle.set_border(Color(1,1,1,0))
			$Circle.set_fill(color)
			$Circle.set_collision_mask_value(3,true)
		"antiproj":
			var color = Globals.normalColor
			$Circle.set_border(color)
			color.a = .1
			$Circle.set_fill(color)
			$Circle.set_collision_mask_value(2,true)
		"kill":
			var color = Globals.normalColor
			$Circle.set_border(Color(1,1,1,0))
			$Circle.set_fill(color)
			$Circle.set_collision_mask_value(3,true)
			$Circle.set_collision_mask_value(2,true)
	if time>0:
		$Timer.start(time)

func _process(delta):
	if effect == "kill":
		modulate.a-=delta*2
		if modulate.a <=0:
			queue_free()
	pass

func _on_circle_area_entered(area):
	match effect:
		"jam":
			if area.is_in_group("Jammable"):
				area.jam(self, -1)
		"antiproj":
			if area.is_in_group("Projectile"):
				area.queue_free()
		"kill":
			if modulate.a >=.9:
				if area.is_in_group("Jammable"):
					area.get_parent().queue_free()
				elif area.is_in_group("Projectile"):
					area.queue_free()
	pass # Replace with function body.

func _on_circle_area_exited(area):
	match effect:
		"jam":
			if area.is_in_group("Jammable"):
				area.jam(self, effectTime)
	pass # Replace with function body.

func _on_timer_timeout():
	match effect:
		"jam":
			for area in $Circle.get_overlapping_areas():
				if area.is_in_group("Jammable"):
					area.jam(self, effectTime)
	queue_free()
	pass # Replace with function body.
