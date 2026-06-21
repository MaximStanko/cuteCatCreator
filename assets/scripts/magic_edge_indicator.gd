extends Node3D

func set_light_color(color: Color):
	$CPUParticles3D.mesh.material.emission = color
