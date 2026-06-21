extends Node3D

var cat_rhombus: PackedScene = preload("res://assets/prefabs/cats/hexen_gatze.tscn")

func summon(shape):
	if shape == "rhombus":
		var rhombus_katze = cat_rhombus.instantiate()
		self.add_child(rhombus_katze)
		$AnimationPlayer.play("summon_car")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "summon_car":
		$AnimationPlayer.play("spinning")
