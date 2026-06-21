extends Node3D

@export var enemies: Array[PackedScene]



func genocide():
	for child in $enemy_holder.get_children():
		child.queue_free()
		global.new_level = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	
	var start_time = Time.get_ticks_usec()
	if $"../enemy_holder".get_child_count() < 20:
		$"../enemy_holder"
		
		var e = enemies.pick_random().instantiate()
		$"../enemy_holder".add_child(e)
	
	if !get_tree().paused:
		$Timer.wait_time = 1
	
