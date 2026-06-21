extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reset_button_down() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_start_button_down() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"../Control".visible = true
	
