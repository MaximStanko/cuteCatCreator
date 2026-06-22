extends Node3D

func _process(delta: float) -> void:
	$AnimationPlayer.play("Take 01")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.play("Take 01")
