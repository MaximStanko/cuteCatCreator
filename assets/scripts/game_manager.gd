extends Node

var player_pos = Vector3(1.523,0.675,4.017)
var player_rot = Vector3(0,180,0)
var time = 0
var sun_location = Vector3(-58.9, -62.9, -23.7)

signal sunset
signal sunrise
signal player_pickup(name)
