extends RigidBody3D

class_name limb

@export_enum("head","arm","leg", "torso") var type = 1
@export_enum("head","arm","leg", "torso","none") var type_2 = 1
@export_enum("left","right") var side = 1

@export var animation_name = ""
@export var limb_name = "limb"
@export var limb_desc = "limb"

@export_category("Combat")
@export var damage = 0
@export var hp = 0

@export_category("other")
@export var speed = 0

var player : CharacterBody3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == 0 or type_2 == 0:
		$CanvasLayer/Control/Node2D/head.disabled = false
	
	if type == 1 or type_2 == 1:
		$CanvasLayer/Control/Node2D/left_arm.disabled = false
		$CanvasLayer/Control/Node2D/right_arm.disabled = false
	
	if type == 2 or type_2 == 2:
		$CanvasLayer/Control/Node2D/left_leg.disabled = false
		$CanvasLayer/Control/Node2D/right_leg.disabled = false
	
	if type == 3 or type_2 == 3:
		$CanvasLayer/Control/Node2D/torso.disabled = false
	
	damage = snapped(damage * randf_range(.8,1.2), .01)
	hp = snapped(hp * randf_range(.8,1.2), .01)
	speed = snapped(speed * randf_range(.8,1.2),.01)
	
	$billboard/title.text = limb_name
	$billboard/desc.text = "Damage " + str(damage) + "\n" + "Hp " + str(hp) + "\n" + "Speed " + str(speed) + "\n" + limb_desc
	
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if get_parent() != get_tree().current_scene:
		freeze = true
	else:
		freeze = false
	
	if side == 0:
		scale = Vector3(-1,1,1)
	if side == 1:
		scale = Vector3(1,1,1)
	
	if $billboard.visible:
		if Input.is_action_just_pressed("f"):
			$CanvasLayer.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_area_3d_area_entered(area: Area3D) -> void:
	$billboard.visible = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	$billboard.visible = false


func _on_right_arm_button_down() -> void:
	reparent(player.get_node("body/right_arm"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer.visible = false
	side = 1
	player.limb_checker()


func _on_left_arm_button_down() -> void:
	reparent(player.get_node("body/left_arm"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer.visible = false
	side = 0
	player.limb_checker()


func _on_head_button_down() -> void:
	reparent(player.get_node("body/head"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer.visible = false
	player.limb_checker()


func _on_torso_button_down() -> void:
	reparent(player.get_node("body/torso"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer.visible = false
	player.limb_checker()


func _on_right_leg_button_down() -> void:
	reparent(player.get_node("body/right_legs"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer.visible = false
	side = 1
	player.limb_checker()


func _on_left_leg_button_down() -> void:
	reparent(player.get_node("body/left_leg"))
	global_position = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	side = 0
	$CanvasLayer.visible = false
