extends Node3D

var current_shape = null

func summon(shape):
	Inventory.is_cat_up = true
	var cat_instance = load(Inventory.shape_to_cat(shape)).instantiate()
	current_shape = shape
	self.add_child(cat_instance)
	$AnimationPlayer.play("summon_car")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "summon_car":
		$AnimationPlayer.play("spinning")
		$"../catname".text = Inventory.shape_to_cat_name(current_shape)
		current_shape = null
