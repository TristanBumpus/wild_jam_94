extends CharacterBody3D

@export_category("Combat")
@export_enum("melee", "range") var attack_type = 0
@export var hp = 0
var max_hp = 0
@export var damage = 1
@export_enum("none", "Big","Small","Long","Heavy","Lucky","Sharp","Dull", "Unlucky") var special_type = "none"

@export var hit_box : Area3D
@export var loot: Array[PackedScene] = []
var attack_speed = 1
var armor = 0

@export var loot_chance : Array[int] = []

@export_category("Movement")
@export_enum("basic") var movement_type = 0
@export var speed = 1.0
@export var nav : NavigationAgent3D
@export var is_effected_by_gravity = true
var luck = 0.0

@export_category("Other")
@export var e_name = "Enemy"

var player: CharacterBody3D

var special_limb = 0
var last_limbs = [null,null,null,null,null,null]

var start = true
var hit_sound = ["res://Assets/sfx/atk_c1.mp3", "res://Assets/sfx/atk_c2.mp3"]

#special effect
var blood_splatter = preload("res://Entitites/effects/blood_splatter.tscn")



func chest_equalizer():
	var head_offset = $body/torso.get_child(0).chest_off_head_set
	var arm_offset = $body/torso.get_child(0).chest_off_set
	var leg_offset = $body/torso.get_child(0).chest_off_set_legs
	
	head_offset.x *= $body/torso.get_child(0).scale.x
	head_offset.y *= $body/torso.get_child(0).scale.x
	head_offset.z *= $body/torso.get_child(0).scale.x
	
	arm_offset.x *= $body/torso.get_child(0).scale.x
	arm_offset.y *= $body/torso.get_child(0).scale.x
	arm_offset.z *= $body/torso.get_child(0).scale.x
	
	leg_offset.x *= $body/torso.get_child(0).scale.x
	leg_offset.y *= $body/torso.get_child(0).scale.x
	leg_offset.z *= $body/torso.get_child(0).scale.x
	
	$CollisionShape3D.scale = $body/torso.get_child(0).scale
	$Area3D/CollisionShape3D.scale = $body/torso.get_child(0).scale
	
	$body/head.position = head_offset
	
	$body/right_leg.position = leg_offset
	$body/left_leg.position = leg_offset * Vector3(-1,1,1)
	
	$body/right_arm.position = arm_offset
	$body/left_arm.position = arm_offset * Vector3(-1,1,1)

func basic_movement():
	$NavigationAgent3D.target_position = player.global_position
	$NavigationAgent3D.path_desired_distance = 20
	var flat_direction = Vector2(
		player.global_position.x - global_position.x,
		player.global_position.z - global_position.z
	).normalized()
	
	var target_angle = flat_direction.angle_to(Vector2.UP)
	
	rotation.y = lerp_angle(rotation.y, target_angle, .05)
	var dir = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func set_animation(node:Node3D,animString:String):
	node.get_parent().rotation = Vector3(0,0,0)
	if animString == "attack":
		node.get_parent().look_at(player.position)
		#if node.get_node("AnimationPlayer").current_animation != "attack":
		node.get_node("AnimationPlayer").play("attack")
	
	elif node.side == 1:
		node.get_node("AnimationPlayer").play(animString, .3)
	else:
		var advance = false
		if node.get_node("AnimationPlayer").current_animation != animString:
			advance = true
		node.get_node("AnimationPlayer").play(animString, .3)
		if advance:
			node.get_node("AnimationPlayer").advance(node.get_node("AnimationPlayer").get_animation(animString).length/ 2)

func melee_attack():
	if velocity.x + velocity.z != 0:
		set_animation($body/left_arm.get_child(0),"walk")
		if global_position.distance_to(player.global_position) > 10:
			set_animation($body/right_arm.get_child(0),"walk")
		set_animation($body/left_leg.get_child(0),"walk")
		set_animation($body/right_leg.get_child(0),"walk")
	
	if global_position.distance_to(player.global_position) < 10 and $body/right_arm.get_child(0).get_node("AnimationPlayer").current_animation != "attack":
		set_animation($body/right_arm.get_child(0), "attack")

func range_attack():
	if velocity.x + velocity.z != 0:
		set_animation($body/left_arm.get_child(0),"walk")
		if global_position.distance_to(player.global_position) > 10 and $body/right_arm.get_child(0).get_node("AnimationPlayer").current_animation != "attack":
			set_animation($body/right_arm.get_child(0),"walk")
		set_animation($body/left_leg.get_child(0),"walk")
		set_animation($body/right_leg.get_child(0),"walk")
	
	if global_position.distance_to(player.global_position) < 10:
		set_animation($body/head.get_child(0), "attack")

func limb_to_check(node,index):
	if node.get_child(0) != last_limbs[index]:
		if last_limbs[index] != null:
			hp -= last_limbs[index].hp
			speed -= last_limbs[index].speed
			armor -= last_limbs[index].armor
			luck -= last_limbs[index].luck
		
		last_limbs[index] = node.get_child(0)
		hp += node.get_child(0).hp
		speed += node.get_child(0).speed
		armor += node.get_child(0).armor
		luck += node.get_child(0).luck

func limb_checker():
	limb_to_check($body/head,0)
	limb_to_check($body/torso,1)
	limb_to_check($body/left_arm,2)
	limb_to_check($body/right_arm,3)
	limb_to_check($body/left_leg,4)
	limb_to_check($body/right_leg,5)
	
	max_hp = hp
	
	chest_equalizer()



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
