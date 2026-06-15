extends Node3D

@onready var init = $RigidBody3D.global_transform



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if get_tree().get_node_count_in_group("enemy") > 0:
		$RigidBody3D.freeze = true
		if $RigidBody3D.global_transform != init:
			var t = create_tween()
			t.tween_property($RigidBody3D,"global_transform",init,1)
			t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
			t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
	else:
		$RigidBody3D.freeze = false
	
	if $RigidBody3D.global_transform != init and $Timer.is_stopped():
		$Timer.start(5)





func _on_timer_timeout() -> void:
	print("Done")
	var t = create_tween()
	t.tween_property($RigidBody3D,"global_transform",init,1)
	t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
	t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
