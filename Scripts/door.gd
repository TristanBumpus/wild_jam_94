extends Node3D

@onready var init = $RigidBody3D.global_transform.origin



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#$HingeJoint3D.set("motor/enable",true)
	
	if get_tree().get_node_count_in_group("enemy") > 0:
		$RigidBody3D.freeze = true
		if $RigidBody3D.position != Vector3.ZERO:
			#global_transform.origin = init
			var t = create_tween()
			t.tween_property($RigidBody3D,"rotation:y",0,1)
			t.parallel().tween_property($RigidBody3D,"position",Vector3.ZERO,1)
			t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
			t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
	else:
		$RigidBody3D.freeze = false
	
	if $RigidBody3D.position != Vector3.ZERO and $Timer.is_stopped():
		$Timer.start(10)





func _on_timer_timeout() -> void:
	var t = create_tween()
	t.tween_property($RigidBody3D,"rotation:y",0,1)
	t.parallel().tween_property($RigidBody3D,"position",Vector3.ZERO,1)
	t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
	t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
