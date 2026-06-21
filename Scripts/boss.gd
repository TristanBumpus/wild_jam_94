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

var limbs : Array
var died = false

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

func new_pos():
	if get_process_delta_time() < 16:
		if $NavigationAgent3D.target_position.distance_to(player.global_position) > 10:
			$NavigationAgent3D.target_position = player.global_position
		if global_position.distance_to(player.global_position) < 10:
			$NavigationAgent3D.target_position = player.global_position
			await get_tree().physics_frame

func basic_movement():
	speed = 10
	
	new_pos()
	
	var flat_direction = Vector2(
		player.global_position.x - global_position.x,
		player.global_position.z - global_position.z
	).normalized()
	var target_angle = flat_direction.angle_to(Vector2.UP)
	var dir = ($NavigationAgent3D.get_next_path_position() - global_position).normalized()
	rotation.y = lerp_angle(rotation.y, target_angle, .05)
	#var path_node = 1
	#while true:
		#if global_position.distance_to(path[path_node]) > 1:
			#dir = (path[path_node] - global_position).normalized()
			#break
		#path_node += 1
	
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
	
	for child in limbs:
		if child.get_node("AnimationPlayer").has_animation("attack"):
			set_animation(child,"attack")

func range_attack():
	if velocity.x + velocity.z != 0:
		set_animation($body/left_arm.get_child(0),"walk")
		if global_position.distance_to(player.global_position) > 10 and $body/right_arm.get_child(0).get_node("AnimationPlayer").current_animation != "attack":
			set_animation($body/right_arm.get_child(0),"walk")
		set_animation($body/left_leg.get_child(0),"walk")
		set_animation($body/right_leg.get_child(0),"walk")
	
	if global_position.distance_to(player.global_position) < 10:
		set_animation($body/head.get_child(0), "attack")

func limb_to_check(node):
	hp += node.hp
	speed += node.speed
	armor += node.armor
	luck += node.luck

func limb_checker():
	
	
	max_hp = hp
	
	for child in limbs:
		limb_to_check(child)



func _ready() -> void:
	
	player = get_tree().get_first_node_in_group("player")
	
	$NavigationAgent3D.target_position = player.global_position
	$NavigationAgent3D.path_desired_distance = 20
	
	var cicle = 1
	
	for child in $body.get_children():
		var ran = randi_range(1,5)
		var l
		
		var angle = cicle * (TAU / $body.get_child_count())
		cicle += 1
		var offset = Vector3(cos(angle), 0 ,sin(angle))
		
		if ran <= 2:
			l = load(global.all_arms.pick_random())
		if ran == 3:
			l = load(global.all_heads.pick_random())
		if ran == 4:
			l = load(global.all_legs.pick_random())
		if ran == 5:
			l = load(global.all_torsos.pick_random())
		
		var li = l.instantiate()
		child.add_child(li)
		limbs.append(li)
		
		
		
		child.position = offset * 6
		child.look_at(offset * 7)
		await get_tree().process_frame



func _process(delta: float) -> void:
	
	if start:
		limb_checker()
		hp = 100
		new_pos()
		start = false
	
	basic_movement()
	melee_attack()
	
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.get_parent().is_in_group("limb"):
		hp -= global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p)
		
		global.play_sound(hit_sound.pick_random(),global_position,-10)
		
		var hit_effect = load("res://Entitites/effects/hit_particule_fx.tscn").instantiate()
		get_tree().current_scene.add_child(hit_effect)
		hit_effect.global_position = global_position
		hit_effect.get_child(0).emitting = true
		
		var pop = load("res://UI/pop_out.tscn").instantiate()
		get_tree().current_scene.add_child(pop)
		pop.global_position = global_position + Vector3.MODEL_FRONT * 2
		pop.text = str(global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p))
		
		
		var b = blood_splatter.instantiate()
		
		get_tree().current_scene.add_child(b)
		
		b.global_position = global_position
		b.global_position.y = 1
		b.global_position.x += randi_range(-1,1)
		b.global_position.z += randi_range(-1,1)
		b.rotation.y = randf_range(0,7)
		
		
		if hp <= 0 and !died:
			died = true
			global.play_sound("res://Assets/sfx/die_c1.mp3",global_position)
			player.current_hp = player.max_hp
			
			var death_effect = load("res://Entitites/effects/blood_explosion.tscn").instantiate()
			get_tree().current_scene.add_child(death_effect)
			death_effect.global_position = global_position
			death_effect.get_child(0).emitting = true
			
			
			
			queue_free()
