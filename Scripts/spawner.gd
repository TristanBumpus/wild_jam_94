extends Node3D

class_name spawner

@export var enemies : Array[PackedScene]



func spawn(timer_number):
	$Timer.start(timer_number)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var e = get_tree().current_scene.get_node("enemy_holder").get_children().pick_random()
	if e != null:
		e.reparent(get_tree().current_scene)
		e.global_position = global_position + Vector3(0,10,0)
		queue_free()
	else:
		$Timer.start(.5)
