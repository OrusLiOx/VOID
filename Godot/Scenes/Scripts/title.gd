extends Node2D

signal button(type)

func _on_start_button_down():
	emit_signal("button","start")

func _on_settings_button_down():
	emit_signal("button","settings")
	
func _on_help_button_down():
	emit_signal("button","help")

