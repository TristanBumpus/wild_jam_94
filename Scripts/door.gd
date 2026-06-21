extends Node3D

@onready var player = get_tree().get_first_node_in_group("player")

var run = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var test = 0
	var location = 0
	for child in get_tree().get_nodes_in_group("enemy"):
		if !child.get_parent().is_in_group("e_holder"):
			test += 1
			location = child.global_position.z
	
	
	if test > 0:
		if player.global_position.z < global_position.z + 1 and location > global_position.z + 1:
			run = true
			$RigidBody3D.freeze = false
		else:
			$RigidBody3D.freeze = true
			if run:
				run = false
				global.play_sound("res://Assets/sfx/close_door_c1.mp3",global_position)
				$RigidBody3D/CollisionShape3D.disabled = true
				var t = create_tween()
				t.tween_property($RigidBody3D,"rotation:y",0,1)
				t.parallel().tween_property($RigidBody3D,"position",Vector3.ZERO,1)
				t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
				t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
				t.tween_property($RigidBody3D/CollisionShape3D,"disabled",false,.1)
				await t.finished
				$AnimationPlayer.play("appear")
	else:
		run = true
		$RigidBody3D.freeze = false
		if $padlock.scale.x == 3:
			$AnimationPlayer.play("disappear")






#func _on_timer_timeout() -> void:
	#$RigidBody3D/CollisionShape3D.disabled = true
	#var t = create_tween()
	#t.tween_property($RigidBody3D,"rotation:y",0,1)
	#t.parallel().tween_property($RigidBody3D,"position",Vector3.ZERO,1)
	#t.tween_property($RigidBody3D,"linear_velocity",Vector3.ZERO,.1)
	#t.tween_property($RigidBody3D,"angular_velocity",Vector3.ZERO,.1)
	#t.tween_property($RigidBody3D/CollisionShape3D,"disabled",false,.1)
