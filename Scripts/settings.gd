extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		visible = !visible
		if !$"../start".visible and !$"../death_screen".visible and !global.choice_active:
			get_tree().paused = !get_tree().paused
			if visible:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_master_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_music_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))


func _on_sfx_s_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))


func _on_full_button_down() -> void:
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_resume_button_down() -> void:
	visible = !visible
	if !$"../start".visible and !$"../death_screen".visible and !global.choice_active:
		get_tree().paused = !get_tree().paused
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
