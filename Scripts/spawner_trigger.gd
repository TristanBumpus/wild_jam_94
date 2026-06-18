extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body.is_in_group("player"):
		if get_parent().find_children("*","spawner") != []:
			for child in get_parent().find_children("*","spawner"):
				child.spawn()
			$Timer.start(5)
			


func _on_timer_timeout() -> void:
	global.difficulty += 10
	get_tree().current_scene.genocide()
