extends CharacterBody3D

class_name Enemy

@export_category("Combat")
@export_enum("melee", "range") var attack_type = 0
@export var hp = 0
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

var player: CharacterBody3D

var special_limb = 0
var last_limbs = [null,null,null,null,null,null]

#special effect
var blood_splatter = preload("res://Entitites/effects/blood_splatter.tscn")



func basic_movement():
	#nav.target_position = player.global_position
	#if nav.is_target_reachable():
	var flat_direction = Vector2(
		player.global_position.x - global_position.x,
		player.global_position.z - global_position.z
	)
	
	var target_angle = flat_direction.angle_to(Vector2.UP)
	
	rotation.y = lerp_angle(rotation.y, target_angle, .05)
	
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func set_animation(node:Node3D,animString:String):
	if animString == "attack":
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
	
	if global_position.distance_to(player.global_position) < 10:
		set_animation($body/right_arm.get_child(0), "attack")

func range_attack():
	if velocity.x + velocity.z != 0:
		set_animation($body/left_arm.get_child(0),"walk")
		if global_position.distance_to(player.global_position) > 10:
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

func rigid_interaction():
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# 3. Check if what we hit is actually a RigidBody3D
		if collider is RigidBody3D:
			# Calculate the direction of the hit (ignoring the Y axis so we don't push it into the floor)
			var push_dir = -collision.get_normal()
			push_dir.y = 0 
			push_dir = push_dir.normalized()
			
			# 4. Apply the impulse at the exact point of contact
			# Multiplying by character velocity makes it push harder if you're running faster
			var push_force = speed / 10
			var final_force = push_dir * push_force
			collider.apply_impulse(final_force, collision.get_position() - collider.global_position)



func _ready() -> void:
	
	add_to_group("enemy")
	
	player = get_tree().get_first_node_in_group("player")
	
	
	var r = randi_range(1,100)
	
	if r == 1:
		special_type = "Big"
	
	$body/head.get_child(0).special_type = special_type
	$body/torso.get_child(0).special_type = special_type
	$body/left_arm.get_child(0).special_type = special_type
	$body/right_arm.get_child(0).special_type = special_type
	$body/left_leg.get_child(0).special_type = special_type
	$body/right_leg.get_child(0).special_type = special_type
	
	limb_checker()

func _process(delta: float) -> void:
	if is_effected_by_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	if movement_type == 0:
		basic_movement()
	
	if attack_type == 0:
		melee_attack()
	if attack_type == 1:
		range_attack()
	
	move_and_slide()
	
	rigid_interaction()


func _on_area_3d_area_entered(area: Area3D) -> void:
	hp -= global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p)
	
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
	
	
	
	if hp <= 0:
		var chance = randi_range(1,100)
		
		var times = 0
		
		for c in loot_chance:
			if chance <= c:
				break
			times += 1
		
		var l = loot[times].instantiate()
		l.special_type = special_type
		get_tree().current_scene.add_child(l)
		l.global_position = global_position + Vector3(0,6,0)
		
		
		queue_free()
