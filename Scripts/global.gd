extends Node

var difficulty = 0
var new_level = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func damage_calc(dam,armor,armor_p):
	if armor - armor_p > 0:
		return dam * (1 - (armor - armor_p)/100)
	else:
		return dam
