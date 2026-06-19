extends CharacterBody3D

class_name Enemy

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
var died = false
var timer

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
	
	if timer.is_stopped():
		$NavigationAgent3D.target_position = player.global_position
		timer.start(.5 * randf_range(.8,1.2))
	
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
	if hp > 0:
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
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(.5 * randf_range(.8,1.2))
	
	player = get_tree().get_first_node_in_group("player")
	
	
	var r = randi_range(1,100)
	
	if r <= 40 * (global.difficulty / 100):
		var types = ["Big","Small","Long","Heavy","Lucky","Sharp","Dull", "Unlucky"]
		#var types = ["Big","Small"]
		special_type = types.pick_random()
	
	
	if r <= 10 * (global.difficulty / 100):
		e_name += " Mutant"
		var ran = randi_range(1,4)
		
		if ran == 1:
			$body/head.get_child(0).queue_free()
			var new_limb = load(global.all_heads.pick_random()).instantiate()
			$body/head.add_child(new_limb)
		if ran == 2:
			$body/torso.get_child(0).queue_free()
			var new_limb = load(global.all_torsos.pick_random()).instantiate()
			$body/torso.add_child(new_limb)
		if ran == 3:
			var ran2 = randi_range(1,2)
			if ran2 == 1:
				$body/left_arm.get_child(0).queue_free()
				var new_limb = load(global.all_arms.pick_random()).instantiate()
				$body/left_arm.add_child(new_limb)
				new_limb.side = 0
			if ran2 == 2:
				$body/right_arm.get_child(0).queue_free()
				var new_limb = load(global.all_arms.pick_random()).instantiate()
				$body/right_arm.add_child(new_limb)
		if ran == 4:
			var ran2 = randi_range(1,2)
			if ran2 == 1:
				$body/left_leg.get_child(0).queue_free()
				var new_limb = load(global.all_legs.pick_random()).instantiate()
				$body/left_leg.add_child(new_limb)
				new_limb.side = 0
			if ran2 == 2:
				$body/right_leg.get_child(0).queue_free()
				var new_limb = load(global.all_legs.pick_random()).instantiate()
				$body/right_leg.add_child(new_limb)
	
	
	
	$body/head.get_child(0).special_type = special_type
	$body/torso.get_child(0).special_type = special_type
	$body/left_arm.get_child(0).special_type = special_type
	$body/right_arm.get_child(0).special_type = special_type
	$body/left_leg.get_child(0).special_type = special_type
	$body/right_leg.get_child(0).special_type = special_type
	
	$NavigationAgent3D.target_position = player.global_position
	$NavigationAgent3D.path_desired_distance = 20


func _physics_process(delta: float) -> void:
	if start:
		limb_checker()
		start = false
	
	if hp > 0:
		chest_equalizer()
	
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
		
		#rigid_interaction()


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
			player.current_hp += player.max_hp / 5
			var chance = randi_range(1,100)
			
			var death_effect = load("res://Entitites/effects/blood_explosion.tscn").instantiate()
			get_tree().current_scene.add_child(death_effect)
			death_effect.global_position = global_position
			death_effect.get_child(0).emitting = true
			
			var times = 0
			
			for c in loot_chance:
				if chance <= c:
					break
				times += 1
			
			var new_loot = [$body/head.get_child(0),$body/torso.get_child(0),$body/left_arm.get_child(0),$body/right_arm.get_child(0),$body/left_leg.get_child(0),$body/right_leg.get_child(0)]
			
			var selected = new_loot.pick_random()
			selected.reparent(get_tree().current_scene)
			selected.global_position.y += 2
			selected.freeze = false
			selected.get_node("CollisionShape3D").disabled = false
			selected.get_node("AnimationPlayer").play("RESET")
			
			queue_free()
