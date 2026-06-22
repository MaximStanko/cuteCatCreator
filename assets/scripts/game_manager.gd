extends Node

var player_pos = Vector3(1.523,0.675,4.017)
var player_rot = Vector3(0,180,0)
var time = 0
var sun_location = Vector3(-58.9, -62.9, -23.7)

signal sunset
signal sunrise
signal player_pickup(name)
signal player_picked_up
signal update_compendium

var world_scene = preload("res://scenes/world888.tscn")
var table_scene = preload("res://scenes/cat_pot_scene.tscn")

func change_to_world_scene():
	get_tree().change_scene_to_packed(world_scene)

func change_to_cat_pot_scene():
	get_tree().change_scene_to_packed(table_scene)
