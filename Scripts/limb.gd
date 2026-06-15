extends RigidBody3D

class_name limb

@export_enum("head","arm","leg", "torso") var type = 1
@export_enum("head","arm","leg", "torso","none") var type_2 = 4
@export_enum("left","right") var side = 1

@export var animation_name = ""
@export var limb_name = "limb"
@export var limb_desc = "limb"

@export_category("Combat")
@export var damage = 0.0
@export var hp = 0.0
@export var attack_speed = 1.0
@export var armor = 0.0
@export var armor_p = 0.0
@export var luck = 0.0

@export_category("other")
@export var speed = 0
@export_enum("none", "Big","Small","Long","Heavy","Lucky","Sharp","Dull", "Unlucky") var special_type = "none"
@export var rotation_diffrence = 0


var player : CharacterBody3D
var billboard



func switch_limb(to_get,s = 1):
	var node = player.get_node(to_get)
	var old = node.get_child(0)
	old.reparent(get_tree().current_scene)
	reparent(node)
	old.global_position = global_position + Vector3(0,3,0)
	old.get_node("choice").visible = false
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$choice.visible = false
	side = s
	sleeping = true
	old.sleeping = false
	player.limb_checker()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Summoning ui elements
	var b = load("res://UI/billboard.tscn")
	var billboard = b.instantiate()
	billboard.position = Vector3.ZERO
	billboard.position.y += 3
	add_child(billboard)
	$billboard.visible = false
	
	
	var c = load("res://UI/choice.tscn")
	var c2 = c.instantiate()
	add_child(c2)
	
	#Connecting buttons
	c2.get_node("Control/Node2D/head").button_down.connect(_on_head_button_down)
	c2.get_node("Control/Node2D/torso").button_down.connect(_on_torso_button_down)
	c2.get_node("Control/Node2D/right_arm").button_down.connect(_on_right_arm_button_down)
	c2.get_node("Control/Node2D/left_arm").button_down.connect(_on_left_arm_button_down)
	c2.get_node("Control/Node2D/right_leg").button_down.connect(_on_right_leg_button_down)
	c2.get_node("Control/Node2D/left_leg").button_down.connect(_on_left_leg_button_down)
	
	add_to_group("limb",true)
	
	#Limb selection
	if type == 0 or type_2 == 0:
		$choice/Control/Node2D/head.disabled = false
	
	if type == 1 or type_2 == 1:
		$choice/Control/Node2D/left_arm.disabled = false
		$choice/Control/Node2D/right_arm.disabled = false
	
	if type == 2 or type_2 == 2:
		$choice/Control/Node2D/left_leg.disabled = false
		$choice/Control/Node2D/right_leg.disabled = false
	
	if type == 3 or type_2 == 3:
		$choice/Control/Node2D/torso.disabled = false
	
	#Basic stats
	damage = snapped(damage * randf_range(.8,1.2), .01)
	hp = snapped(hp * randf_range(.8,1.2), .01)
	speed = snapped(speed * randf_range(.8,1.2),.01)
	armor = snapped(armor * randf_range(.8,1.2), .01)
	attack_speed = snapped(attack_speed * randf_range(.8,1.2), .01)
	armor_p = snapped(armor_p * randf_range(.8,1.2),.01)
	
	#Set up special types
	can_sleep = false
	if special_type == "Big":
		scale = Vector3(2,2,2)
		damage *= 1.5
		attack_speed *= .5
		hp *= 2
	
	if special_type == "Small":
		damage *= .5
		attack_speed *= 2.5
		hp *= .75
		speed *= 2
	
	if special_type == "Heavy":
		attack_speed *= .5
		damage *= .5
		hp *= 3
		armor *= 2
		speed *= .5
	
	if special_type == "Lucky":
		luck *= 1.5
	
	if special_type == "Sharp":
		armor_p *= 2
	
	if special_type == "Dull":
		armor_p /= 2
		damage *= 1.1
	
	if special_type == "Unlucky":
		luck *= .5
	
	#Hover info
	var s = ""
	if special_type != "none":
		s = special_type + " "
	
	$billboard/title.text = s + limb_name
	$billboard/desc.text = "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	
	#Choice tool tips
	$choice/Control/Node2D/head.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$choice/Control/Node2D/torso.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$choice/Control/Node2D/right_arm.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$choice/Control/Node2D/left_arm.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$choice/Control/Node2D/right_leg.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$choice/Control/Node2D/left_leg.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if type == 1 or type_2 == 1:
		if get_parent() != get_tree().current_scene:
			if get_parent().get_parent().get_parent().is_in_group("player"):
				$attack_box.set_collision_layer_value(2,true)
				$attack_box.set_collision_layer_value(3,false)
			else:
				$attack_box.set_collision_layer_value(3,true)
				$attack_box.set_collision_layer_value(2,false)
	
	if get_parent() != get_tree().current_scene:
		$AnimationPlayer.speed_scale = attack_speed
		#sleeping = true
		$choice.visible = false
		$billboard.visible = false
		$CollisionShape3D.disabled = true
		position = Vector3.ZERO
		rotation = Vector3.ZERO
	else:
		#sleeping = false
		$CollisionShape3D.disabled = false
		$AnimationPlayer.play("RESET")
	
	if side == 0:
		scale = Vector3(-1,1,1)
		if special_type == "Big":
			scale = Vector3(-2,2,2)
		if special_type == "Small":
			scale = Vector3(-.5,.5,.5)
	if side == 1:
		scale = Vector3(1,1,1)
		if special_type == "Big":
			scale = Vector3(2,2,2)
		if special_type == "Small":
			scale = Vector3(.5,.5,.5)
	
	if $billboard.visible:
		if Input.is_action_just_pressed("f"):
			$choice.visible = true
			
			$choice/Control/Node2D/head.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" +  "\nOld" + "\n" + "Damage " + str(player.get_node("body/head").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/head").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/head").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/head").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/head").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/head").get_child(0).speed) + "\n"
			$choice/Control/Node2D/torso.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" +  "\nOld" + "\n" + "Damage " + str(player.get_node("body/torso").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/torso").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/torso").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/torso").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/torso").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/torso").get_child(0).speed) + "\n"
			$choice/Control/Node2D/right_arm.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" + "\nOld" + "\n" + "Damage " + str(player.get_node("body/right_arm").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/right_arm").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/right_arm").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/right_arm").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/right_arm").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/right_arm").get_child(0).speed) + "\n"
			$choice/Control/Node2D/left_arm.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" +  "\nOld" + "\n" + "Damage " + str(player.get_node("body/left_arm").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/left_arm").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/left_arm").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/left_arm").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/left_arm").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/left_arm").get_child(0).speed) + "\n"
			$choice/Control/Node2D/right_leg.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" +  "\nOld" + "\n" + "Damage " + str(player.get_node("body/right_leg").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/right_leg").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/right_leg").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/right_leg").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/right_leg").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/right_leg").get_child(0).speed) + "\n"
			$choice/Control/Node2D/left_leg.tooltip_text = "New" + "\n" + "Damage " + str(damage) + "\n" + "Attack speed +" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n" +  "\nOld" + "\n" + "Damage " + str(player.get_node("body/left_leg").get_child(0).damage) + "\n" + "Attack speed +" + str(player.get_node("body/left_leg").get_child(0).attack_speed) + "\n" + "Armor Percing " + str(player.get_node("body/left_leg").get_child(0).armor_p) + "\n" + "Hp +" + str(player.get_node("body/left_leg").get_child(0).hp) + "\n" + "Armor +" + str(player.get_node("body/left_leg").get_child(0).armor) + "\n" +"Speed +" + str(player.get_node("body/left_leg").get_child(0).speed) + "\n"
			
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



func _on_right_arm_button_down() -> void:
	switch_limb("body/right_arm")


func _on_left_arm_button_down() -> void:
	switch_limb("body/left_arm",0)


func _on_head_button_down() -> void:
	switch_limb("body/head")


func _on_torso_button_down() -> void:
	switch_limb("body/torso")


func _on_right_leg_button_down() -> void:
	switch_limb("body/right_leg")


func _on_left_leg_button_down() -> void:
	switch_limb("body/left_leg",0)
