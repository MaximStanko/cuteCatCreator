extends Node3D

func summon(shape):
	var cat_instance = load(Inventory.shape_to_cat(shape)).instantiate()
	self.add_child(cat_instance)
	$AnimationPlayer.play("summon_car")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "summon_car":
		$AnimationPlayer.play("spinning")
