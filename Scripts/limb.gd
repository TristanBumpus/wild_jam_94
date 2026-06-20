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
@export var image = load("res://Assets/gui/limb/human/human_arm.png")
@export var speed = 0
@export_enum("none", "Big","Small","Long","Heavy","Lucky","Sharp","Dull", "Unlucky") var special_type = "none"
@export var rotation_diffrence = 0
@export var chest_off_set = Vector3(0,0,0)
@export var chest_off_set_legs = Vector3(0,0,0)
@export var chest_off_head_set = Vector3(0,0,0)

var player : CharacterBody3D
var billboard



func switch_limb(to_get,s = 1):
	
	global.play_sound("res://Assets/sfx/equip_limb_c2.mp3",global_position)
	global.choice_active = false
	var node = player.get_node(to_get)
	var old = node.get_child(0)
	old.reparent(get_tree().current_scene)
	reparent(node)
	old.global_position = global_position + Vector3(0,3,0)
	old.get_node("choice").visible = false
	old.freeze = false
	old.get_node("CollisionShape3D").disabled = false
	old.get_node("AnimationPlayer").play("RESET")
	
	if has_node("attack_box"):
		$AnimationPlayer.speed_scale = attack_speed
		if get_parent() != get_tree().current_scene:
			if get_parent().get_parent().get_parent().is_in_group("player"):
				$attack_box.set_collision_layer_value(2,true)
				$attack_box.set_collision_layer_value(3,false)
				$attack_box.set_collision_mask_value(2,true)
				$attack_box.set_collision_mask_value(3,false)
			else:
				$attack_box.set_collision_layer_value(3,true)
				$attack_box.set_collision_layer_value(2,false)
				$attack_box.set_collision_mask_value(3,true)
				$attack_box.set_collision_mask_value(2,false)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$choice.visible = false
	$billboard.visible = false
	$CollisionShape3D.disabled = true
	side = s
	freeze = true
	
	if s == 0 and type != 0:
		scale = Vector3(-1,1,1)
		if special_type == "Big":
			scale = Vector3(-2,2,2)
		if special_type == "Small":
			scale = Vector3(-.5,.5,.5)
	else:
		scale = Vector3(1,1,1)
		if special_type == "Big":
			scale = Vector3(2,2,2)
		if special_type == "Small":
			scale = Vector3(.5,.5,.5)
	player.limb_checker()

func tooltip(old_limb,show_attack = false):
	$choice/Control/RichTextLabel.text = ""
	$choice/Control/RichTextLabel2.text = ""
	
	$choice/Control/RichTextLabel.text = "New " + $billboard/title.text
	$choice/Control/RichTextLabel2.text = "Old " + old_limb.get_node("billboard/title").text
	
	$choice/Control/RichTextLabel.text += "\n"
	$choice/Control/RichTextLabel2.text += "\n"
	
	if show_attack:
		if old_limb.damage > damage:
			$choice/Control/RichTextLabel2.append_text("Damage: [color=green]%s[/color]\n" % [str(old_limb.damage)])
			$choice/Control/RichTextLabel.append_text("Damage: [color=red]%s[/color]\n" % [str(damage)])
		elif old_limb.damage == damage:
			$choice/Control/RichTextLabel2.append_text("Damage: [color=yellow]%s[/color]\n" % [str(old_limb.damage)])
			$choice/Control/RichTextLabel.append_text("Damage: [color=yellow]%s[/color]\n" % [str(damage)])
		else:
			$choice/Control/RichTextLabel2.append_text("Damage: [color=red]%s[/color]\n" % [str(old_limb.damage)])
			$choice/Control/RichTextLabel.append_text("Damage: [color=green]%s[/color]\n" % [str(damage)])
		
		if old_limb.attack_speed > attack_speed:
			$choice/Control/RichTextLabel2.append_text("Attack Speed: [color=green]%s[/color]\n" % [str(old_limb.attack_speed)])
			$choice/Control/RichTextLabel.append_text("Attack Speed: [color=red]%s[/color]\n" % [str(attack_speed)])
		elif old_limb.attack_speed == attack_speed:
			$choice/Control/RichTextLabel2.append_text("Attack Speed: [color=yellow]%s[/color]\n" % [str(old_limb.attack_speed)])
			$choice/Control/RichTextLabel.append_text("Attack Speed: [color=yellow]%s[/color]\n" % [str(attack_speed)])
		else:
			$choice/Control/RichTextLabel2.append_text("Attack Speed: [color=red]%s[/color]\n" % [str(old_limb.attack_speed)])
			$choice/Control/RichTextLabel.append_text("Attack Speed: [color=green]%s[/color]\n" % [str(attack_speed)])
		
		if old_limb.armor_p > armor_p:
			$choice/Control/RichTextLabel2.append_text("Armor Penetration: [color=green]%s[/color]\n" % [str(old_limb.armor_p)])
			$choice/Control/RichTextLabel.append_text("Armor Penetration: [color=red]%s[/color]\n" % [str(armor_p)])
		elif old_limb.armor_p == armor_p:
			$choice/Control/RichTextLabel2.append_text("Armor Penetration: [color=yellow]%s[/color]\n" % [str(old_limb.armor_p)])
			$choice/Control/RichTextLabel.append_text("Armor Penetration: [color=yellow]%s[/color]\n" % [str(armor_p)])
		else:
			$choice/Control/RichTextLabel2.append_text("Armor Penetration: [color=red]%s[/color]\n" % [str(old_limb.armor_p)])
			$choice/Control/RichTextLabel.append_text("Armor Penetration: [color=green]%s[/color]\n" % [str(armor_p)])
		
		if old_limb.damage / old_limb.attack_speed > damage / attack_speed:
			$choice/Control/RichTextLabel2.append_text("DPS: [color=green]%s[/color]\n" % [str(snapped(old_limb.damage / old_limb.attack_speed,.01))])
			$choice/Control/RichTextLabel.append_text("DPS: [color=red]%s[/color]\n" % [str(snapped(damage / attack_speed,.01))])
		elif old_limb.damage / old_limb.attack_speed == damage / attack_speed:
			$choice/Control/RichTextLabel2.append_text("DPS: [color=yellow]%s[/color]\n" % [str(snapped(old_limb.damage / old_limb.attack_speed,.01))])
			$choice/Control/RichTextLabel.append_text("DPS: [color=yellow]%s[/color]\n" % [str(snapped(damage / attack_speed,.01))])
		else:
			$choice/Control/RichTextLabel2.append_text("DPS: [color=red]%s[/color]\n" % [str(snapped(old_limb.damage / old_limb.attack_speed,.01))])
			$choice/Control/RichTextLabel.append_text("DPS: [color=green]%s[/color]\n" % [str(snapped(damage / attack_speed,.1))])
	
	
	if old_limb.hp > hp:
		$choice/Control/RichTextLabel2.append_text("Hp: [color=green]%s[/color]\n" % [str(old_limb.hp)])
		$choice/Control/RichTextLabel.append_text("Hp: [color=red]%s[/color]\n" % [str(hp)])
	elif old_limb.hp == hp:
		$choice/Control/RichTextLabel2.append_text("Hp: [color=yellow]%s[/color]\n" % [str(old_limb.hp)])
		$choice/Control/RichTextLabel.append_text("Hp: [color=yellow]%s[/color]\n" % [str(hp)])
	else:
		$choice/Control/RichTextLabel2.append_text("Hp: [color=red]%s[/color]\n" % [str(old_limb.hp)])
		$choice/Control/RichTextLabel.append_text("Hp: [color=green]%s[/color]\n" % [str(hp)])
	
	if old_limb.armor > armor:
		$choice/Control/RichTextLabel2.append_text("Armor: [color=green]%s[/color]\n" % [str(old_limb.armor)])
		$choice/Control/RichTextLabel.append_text("Armor: [color=red]%s[/color]\n" % [str(armor)])
	elif old_limb.armor == armor:
		$choice/Control/RichTextLabel2.append_text("Armor: [color=yellow]%s[/color]\n" % [str(old_limb.armor)])
		$choice/Control/RichTextLabel.append_text("Armor: [color=yellow]%s[/color]\n" % [str(armor)])
	else:
		$choice/Control/RichTextLabel2.append_text("Armor: [color=red]%s[/color]\n" % [str(old_limb.armor)])
		$choice/Control/RichTextLabel.append_text("Armor: [color=green]%s[/color]\n" % [str(armor)])
	
	if old_limb.speed > speed:
		$choice/Control/RichTextLabel2.append_text("Speed: [color=green]%s[/color]\n" % [str(old_limb.speed)])
		$choice/Control/RichTextLabel.append_text("Speed: [color=red]%s[/color]\n" % [str(speed)])
	elif old_limb.speed == speed:
		$choice/Control/RichTextLabel2.append_text("Speed: [color=yellow]%s[/color]\n" % [str(old_limb.speed)])
		$choice/Control/RichTextLabel.append_text("Speed: [color=yellow]%s[/color]\n" % [str(speed)])
	else:
		$choice/Control/RichTextLabel2.append_text("Speed: [color=red]%s[/color]\n" % [str(old_limb.speed)])
		$choice/Control/RichTextLabel.append_text("Speed: [color=green]%s[/color]\n" % [str(speed)])
	
	if old_limb.luck > luck:
		$choice/Control/RichTextLabel2.append_text("Luck: [color=green]%s[/color]\n" % [str(old_limb.luck)])
		$choice/Control/RichTextLabel.append_text("Luck: [color=red]%s[/color]\n" % [str(luck)])
	elif old_limb.luck == luck:
		$choice/Control/RichTextLabel2.append_text("Luck: [color=yellow]%s[/color]\n" % [str(old_limb.luck)])
		$choice/Control/RichTextLabel.append_text("Luck: [color=yellow]%s[/color]\n" % [str(luck)])
	else:
		$choice/Control/RichTextLabel2.append_text("Luck: [color=red]%s[/color]\n" % [str(old_limb.luck)])
		$choice/Control/RichTextLabel.append_text("Luck: [color=green]%s[/color]\n" % [str(luck)])
	
	
	#$choice/Control/RichTextLabel2.text
	#$choice/Control/RichTextLabel2.text += str(old_limb.damage)

func play_step():
	if get_parent().get_parent().get_parent().is_in_group("player"):
		global.play_sound(["res://Assets/sfx/step_c1.mp3","res://Assets/sfx/step_c2.mp3","res://Assets/sfx/step_c3.mp3"].pick_random(), global_position,-22)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	linear_damp = 2
	angular_damp = 2
	mass = .5
	
	#var enabler: VisibleOnScreenEnabler3D
	#enabler = VisibleOnScreenEnabler3D.new()
	#add_child(enabler)
	#enabler.aabb = AABB(Vector3(-1.403,-2.399,-1.0),Vector3(2.806,4.798,2.0))
	#enabler.enable_mode = VisibleOnScreenEnabler3D.ENABLE_MODE_ALWAYS
	#enabler.process_mode = Node.PROCESS_MODE_DISABLED
	
	for child in find_children("*","MeshInstance3D"):
		child.set_layer_mask_value(1,false)
		child.set_layer_mask_value(2,true)
	
	#Summoning ui elements
	if !has_node("billboard"):
		var b = load("res://UI/billboard.tscn")
		var billboard = b.instantiate()
		add_child(billboard)
	$billboard.visible = false
	
	if !has_node("choice"):
		var c = load("res://UI/choice.tscn")
		var c2 = c.instantiate()
		add_child(c2)
	
	#Connecting buttons
	$choice.get_node("Control/Node2D/head").button_down.connect(_on_head_button_down)
	$choice.get_node("Control/Node2D/torso").button_down.connect(_on_torso_button_down)
	$choice.get_node("Control/Node2D/right_arm").button_down.connect(_on_right_arm_button_down)
	$choice.get_node("Control/Node2D/left_arm").button_down.connect(_on_left_arm_button_down)
	$choice.get_node("Control/Node2D/right_leg").button_down.connect(_on_right_leg_button_down)
	$choice.get_node("Control/Node2D/left_leg").button_down.connect(_on_left_leg_button_down)
	$choice.get_node("Control/Node2D/end").button_down.connect(end_choice)
	
	
	
	add_to_group("limb",true)
	
	#Limb selection
	if type == 0 or type_2 == 0:
		$choice/Control/Node2D/head.disabled = false
		$choice.get_node("Control/Node2D/head").mouse_entered.connect(_head_hover)
	
	if type == 1 or type_2 == 1:
		$choice/Control/Node2D/left_arm.disabled = false
		$choice/Control/Node2D/right_arm.disabled = false
		$choice.get_node("Control/Node2D/right_arm").mouse_entered.connect(_right_arm_hover)
		$choice.get_node("Control/Node2D/left_arm").mouse_entered.connect(_left_arm_hover)
	
	if type == 2 or type_2 == 2:
		$choice/Control/Node2D/left_leg.disabled = false
		$choice/Control/Node2D/right_leg.disabled = false
		$choice.get_node("Control/Node2D/right_leg").mouse_entered.connect(_right_leg_hover)
		$choice.get_node("Control/Node2D/left_leg").mouse_entered.connect(_left_leg_hover)
	
	if type == 3 or type_2 == 3:
		$choice/Control/Node2D/torso.disabled = false
		$choice.get_node("Control/Node2D/torso").mouse_entered.connect(_torso_hover)
	
	#Basic stats
	damage = snapped(damage * randf_range(.8,1.2), .01) * (global.difficulty/100)
	hp = snapped(hp * randf_range(.8,1.2), .01) * (global.difficulty/100)
	speed = snapped(speed * randf_range(.8,1.2),.01) * (global.difficulty/100)
	armor = snapped(armor * randf_range(.8,1.2), .01) * (global.difficulty/100)
	attack_speed = snapped(attack_speed * randf_range(.8,1.2), .01) * (global.difficulty/100)
	armor_p = snapped(armor_p * randf_range(.8,1.2),.01) * (global.difficulty/100)
	
	#Set up special types
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
		armor += snapped(1 * randf_range(.8,1.2),.01) * (global.difficulty/100)
		speed *= .5
	
	if special_type == "Lucky":
		luck *= 1.5
		luck += snapped(1 * randf_range(.8,1.2),.01) * (global.difficulty/100)
	
	if special_type == "Sharp":
		armor_p *= 2
		if armor_p <= 0:
			armor_p = snapped(1 * randf_range(.8,1.2),.01) * (global.difficulty/100)
	
	if special_type == "Dull":
		armor_p /= 2
		damage *= 1.1
	
	if special_type == "Unlucky":
		luck *= .5
	
	#Set the scales
	if side == 0 and type != 0:
		scale = Vector3(-1,1,1)
		if special_type == "Big":
			scale = Vector3(-2,2,2)
		if special_type == "Small":
			scale = Vector3(-.5,.5,.5)
	else:
		scale = Vector3(1,1,1)
		if special_type == "Big":
			scale = Vector3(2,2,2)
		if special_type == "Small":
			scale = Vector3(.5,.5,.5)
	
	player = get_tree().get_first_node_in_group("player")
	
	var s = ""
	if special_type != "none":
		s = special_type + " "
	$billboard/title.text = s + limb_name
	$billboard/desc.text = "Damage " + str(damage) + "\n" + "Attack speed" + str(attack_speed) + "\n" + "Armor Percing " + str(armor_p) + "\n" + "Hp +" + str(hp) + "\n" + "Armor +" + str(armor) + "\n" +"Speed +" + str(speed) + "\n"
	$billboard.visible = false
	
	if get_tree().current_scene != get_parent() and !get_parent().is_in_group("first_level_is_special_cus_the_limbs_demand_it"):
		freeze = true
		position = Vector3.ZERO
		rotation = Vector3.ZERO
		$CollisionShape3D.disabled = true
	
	if has_node("attack_box"):
		$AnimationPlayer.speed_scale = attack_speed
		if get_parent() != get_tree().current_scene:
			if get_parent().get_parent().get_parent().is_in_group("player"):
				$attack_box.set_collision_layer_value(2,true)
				$attack_box.set_collision_layer_value(3,false)
				$attack_box.set_collision_mask_value(2,true)
				$attack_box.set_collision_mask_value(3,false)
			else:
				$attack_box.set_collision_layer_value(3,true)
				$attack_box.set_collision_layer_value(2,false)
				$attack_box.set_collision_mask_value(3,true)
				$attack_box.set_collision_mask_value(2,false)



func _physics_process(delta: float) -> void:
	
	
	if $choice.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$billboard.visible = false
		if global_position.distance_to(player.global_position) > 15:
			$choice.visible = false
			global.choice_active = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if $billboard.visible:
		if Input.is_action_just_pressed("f") and !global.choice_active:
			$choice.visible = true
			global.choice_active = false
			
			$choice/Control/Node2D/head/TextureRect.texture = player.get_node("body/head").get_child(0).image
			$choice/Control/Node2D/torso/TextureRect.texture = player.get_node("body/torso").get_child(0).image
			$choice/Control/Node2D/right_arm/TextureRect.texture = player.get_node("body/right_arm").get_child(0).image
			$choice/Control/Node2D/left_arm/TextureRect.texture = player.get_node("body/left_arm").get_child(0).image
			$choice/Control/Node2D/right_leg/TextureRect.texture = player.get_node("body/right_leg").get_child(0).image
			$choice/Control/Node2D/left_leg/TextureRect.texture = player.get_node("body/left_leg").get_child(0).image
			
			
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


func end_choice():
	$choice.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	global.choice_active


func _head_hover():
	tooltip(player.get_node("body/head").get_child(0))


func _torso_hover():
	tooltip(player.get_node("body/torso").get_child(0))


func _left_arm_hover():
	tooltip(player.get_node("body/left_arm").get_child(0),true)


func _right_arm_hover():
	tooltip(player.get_node("body/right_arm").get_child(0),true)


func _left_leg_hover():
	tooltip(player.get_node("body/left_leg").get_child(0))


func _right_leg_hover():
	tooltip(player.get_node("body/right_leg").get_child(0))
