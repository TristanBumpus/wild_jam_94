extends Node3D

class_name spawner

@export var enemies : Array[PackedScene]



func spawn():
	
	var e = enemies.pick_random().instantiate()
	get_tree().current_scene.add_child(e)
	e.global_position = global_position + Vector3(0,10,0)
	print("w")
	queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
