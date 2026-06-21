extends CharacterBody3D

@export_category("Combat")
@export var damage = 1
@export var current_hp = 5
@export var max_hp = 5

var speed = 10.0
var attack_speed = 1
var armor = 0
var jump_speed = 9
var luck = 0.0
var mouse_sensitivity = .005
@onready var cam = $Camera3D

var attacking = [false,false]
var last_limbs = [null,null,null,null,null,null]
var cam_pos = Vector3(0,1,-.9)
@export var limb_slots : Array[Node3D]

@export_category("Camera Shake")
@export var decay : float = 0.8 # Time it takes to reach 0% of trauma
@export var max_offset : Vector2 = Vector2(100, 75) # Max hor/ver shake in pixels
@export var max_roll : float = 0.1 # Maximum rotation in radians (use sparingly)
@export var follow_node : Node2D # Node to follow (assign this to your player)

var trauma : float = 0.0 # Current shake strength
var trauma_power : int = 2 # Trauma exponent. Increase for more extreme shaking
@export var disabled = false


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
	
	
	$body/head.position = head_offset
	
	$body/right_leg.position = leg_offset
	$body/left_leg.position = leg_offset * Vector3(-1,1,1)
	
	$body/right_arm.position = arm_offset
	$body/left_arm.position = arm_offset * Vector3(-1,1,1)

func cheats():
	if Input.is_action_just_pressed("k"):
		trigger_shake(.5)
		for child in get_tree().get_nodes_in_group("enemy"):
			child.hp = 0
	if Input.is_action_just_pressed("e"):
		$ui.visible = false
		var i = get_viewport().get_texture().get_image()
		i.save_png("res://screenshots/"+ str(randi()) +".png")
		$ui.visible = true
	if Input.is_action_just_pressed("p"):
		global.difficulty = 250
		for child in find_children("*","limb"):
			child.reset()
		last_limbs = [null,null,null,null,null,null]
		limb_checker()
		global_position = get_tree().get_first_node_in_group("boss_room").global_position + Vector3(0,10,0)
		#for child in get_tree().get_nodes_in_group("enemy"):
			#child.queue_free()

func movement(delta):
	
	var speed_mod = 1
	
	if Input.is_action_just_pressed("shift"):
		speed_mod = 10
	elif Input.is_action_pressed("shift"):
		speed_mod = 2
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed * speed_mod
		velocity.z = direction.z * speed * speed_mod
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func attack():
	if attacking[0] and $attack_cooldown0.is_stopped():
		attacking[0] = false
	if attacking[1] and $attack_cooldown1.is_stopped():
		attacking[1] = false
	
	
	if Input.is_action_pressed("left_click") and !attacking[0]:
		attacking[0] = true
		global.play_sound("res://Assets/sfx/whoosh_c1.mp3",global_position,-20)
	if Input.is_action_pressed("right_click") and !attacking[1]:
		attacking[1] = true
		global.play_sound("res://Assets/sfx/whoosh_c1.mp3",global_position,-20)


func limb_to_check(node,index):
	if node.get_child(0) != last_limbs[index]:
		if last_limbs[index] != null:
			max_hp -= last_limbs[index].hp
			current_hp -= last_limbs[index].hp
			speed -= last_limbs[index].speed
			armor -= last_limbs[index].armor
			luck -= last_limbs[index].luck
		
		last_limbs[index] = node.get_child(0)
		max_hp += node.get_child(0).hp
		current_hp += node.get_child(0).hp
		speed += node.get_child(0).speed
		armor += node.get_child(0).armor
		luck += node.get_child(0).luck
		if node.get_child(0).has_node("attack_box"):
			node.get_child(0).get_node("attack_box").area_entered.connect(update_enemy_ui)

func limb_checker():
	limb_to_check($body/head,0)
	limb_to_check($body/torso,1)
	limb_to_check($body/left_arm,2)
	limb_to_check($body/right_arm,3)
	limb_to_check($body/left_leg,4)
	limb_to_check($body/right_leg,5)
	
	chest_equalizer()

func set_animation(node:Node3D,animString:String):
	if animString == "attack":
		#if node.get_node("AnimationPlayer").current_animation != "attack":
		node.get_node("AnimationPlayer").play(animString, .3)
		node.get_node("AnimationPlayer").advance(0)
	elif node.side == 1:
		if node.get_node("AnimationPlayer").current_animation != "attack":
			node.get_node("AnimationPlayer").play(animString, .3)
	else:
		if node.get_node("AnimationPlayer").current_animation != "attack":
			var advance = false
			if node.get_node("AnimationPlayer").current_animation != animString:
				advance = true
			node.get_node("AnimationPlayer").play(animString, .3)
			if advance:
				node.get_node("AnimationPlayer").seek(node.get_node("AnimationPlayer").get_animation(animString).length/ 2 * node.get_node("AnimationPlayer").speed_scale,true)

func animation_states():
	if velocity.x + velocity.z != 0:
		#set_animation($body/head.get_child(0),"walk")
		#set_animation($body/torso.get_child(0),"walk")
		set_animation($body/left_arm.get_child(0),"walk")
		set_animation($body/right_arm.get_child(0),"walk")
		set_animation($body/left_leg.get_child(0),"walk")
		set_animation($body/right_leg.get_child(0),"walk")
	else:
		set_animation($body/left_arm.get_child(0),"idle")
		set_animation($body/right_arm.get_child(0),"idle")
		set_animation($body/left_leg.get_child(0),"idle")
		set_animation($body/right_leg.get_child(0),"idle")
	if attacking[0] or attacking[1]:
		if attacking[0]:
			for child in limb_slots:
				if child.get_child(0).get_node("AnimationPlayer").has_animation("attack"):
					set_animation(child.get_child(0),"attack")
				attacking[0] = false

func _unhandled_input(event):
	# Handle vertical/horizontal camera rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		$body/left_arm.rotation.x = cam.rotation.x + deg_to_rad(10 + $body/left_arm.get_child(0).rotation_diffrence)
		$body/right_arm.rotation.x = cam.rotation.x + deg_to_rad(10 + $body/right_arm.get_child(0).rotation_diffrence)
		
		$body/left_arm.rotation.x = clamp(cam.rotation.x, deg_to_rad(-50), deg_to_rad(90))
		$body/right_arm.rotation.x = clamp(cam.rotation.x, deg_to_rad(-50), deg_to_rad(90))

func update_ui():
	
	if current_hp > max_hp:
		current_hp = max_hp
	
	if $ui/Control/health_bar.value != current_hp:
		var t = create_tween()
		t.tween_property($ui/Control/health_bar,"value",current_hp,.2)
	
	$ui/Control/health.text = "hp: " + str(current_hp)
	
	
	$ui/Control/health_bar.max_value = max_hp

func rigid_interaction():
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			push_dir.y = 0 
			push_dir = push_dir.normalized()
			
			var push_force = speed / 10
			var final_force = push_dir * push_force
			collider.apply_impulse(final_force, collision.get_position() - collider.global_position)

func shake(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		var amount = pow(trauma, trauma_power)
		#cam.rotation = max_roll * amount * randf_range(-1, 1)
		cam.h_offset = max_offset.x * amount * randf_range(-1, 1)
		cam.v_offset = max_offset.y * amount * randf_range(-1, 1)

func trigger_shake(amount : float):
	trauma = min(trauma + amount, 1.0)
	if trauma > .1:
		trauma = .1



func _ready() -> void:
	limb_checker()

func _physics_process(delta: float) -> void:
	if !disabled:
		cam.position = cam_pos * $body/torso.get_child(0).scale.x
		
		if global_position.y < -5:
			$ui/Control/health_bar.value = current_hp
			
			$ui/Control/health.text = "hp: " + str(current_hp)
			
			$ui/death_screen.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true
		
		shake(delta)
		update_ui()
		attack()
		movement(delta)
		cheats()
		animation_states()
		
		move_and_slide()
	else:
		$ui.visible = false
		for child in limb_slots:
			child.get_child(0).scale = Vector3(.5,.5,.5)
		$body/torso.visible = true
		limb_checker()
	

func _process(delta: float) -> void:
	
	rigid_interaction()



func _on_hit_box_area_entered(area: Area3D) -> void:
	current_hp -= snapped(global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p),.01)
	
	if current_hp <= 0:
		$ui/Control/health_bar.value = current_hp
		
		$ui/Control/health.text = "hp: " + str(current_hp)
		
		$ui/death_screen.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#get_tree().paused = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("limb") and global.hover_limb == null:
		if attacking[0] == true and attacking[1] == true and get_tree().get_node_count_in_group("enemy") > 0:
			pass
		else:
			global.hover_limb = body
			body.get_node("billboard").visible = true
	
	if body.is_in_group("enemy") and body != null:
		if body.hp >= 0:
			$ui/Control/enemy.visible = true
			$ui/Control/enemy_hp.visible = true
			
			$ui/Control/enemy_hp.max_value = body.max_hp
			$ui/Control/enemy_hp.value = body.hp
			if body.special_type != "none":
				$ui/Control/enemy.text = body.get_node("body/head").get_child(0).special_type + " " + body.e_name
			else:
				$ui/Control/enemy.text = body.e_name


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("limb") and body == global.hover_limb:
		global.hover_limb = null
		body.get_node("billboard").visible = false
	if body.is_in_group("enemy"):
		$ui/Control/enemy.visible = false
		$ui/Control/enemy_hp.visible = false


func update_enemy_ui(area: Area3D) -> void:
	if area.get_parent().is_in_group("enemy"):
		trigger_shake(.1)
	if area.get_parent() != null and area.get_parent().is_in_group("enemy"):
		if area.get_parent().hp > 0:
			$ui/Control/enemy.visible = true
			$ui/Control/enemy_hp.visible = true
			
			$ui/Control/enemy_hp.max_value = area.get_parent().max_hp
			$ui/Control/enemy_hp.value = area.get_parent().hp
			if area.get_parent().special_type != "none":
				$ui/Control/enemy.text = area.get_parent().get_node("body/head").get_child(0).special_type + " " + area.get_parent().e_name
			else:
				$ui/Control/enemy.text = area.get_parent().e_name


func _on_attack_cooldown_0_timeout() -> void:
	attacking[0] = false


func _on_attack_cooldown_1_timeout() -> void:
	attacking[1] = false
