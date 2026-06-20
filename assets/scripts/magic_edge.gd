extends MeshInstance3D

func set_light_color(color: Color):
	mesh.material.emission = color
