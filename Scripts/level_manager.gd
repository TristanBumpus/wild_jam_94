extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if global.deaths >= 3:
		if has_node("Label3D3"):
			$Label3D3.visible = true
	
	if player.global_position.z < global_position.z:
		if global_position.distance_to(player.global_position) > 150:
			visible = false
		else:
			visible = true
	else:
		if global_position.distance_to(player.global_position) > 500:
			visible = false
		else:
			visible = true
	
	
