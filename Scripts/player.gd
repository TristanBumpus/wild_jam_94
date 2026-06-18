extends CharacterBody3D

@export_category("Combat")
@export var damage = 1
@export var current_hp = 5
@export var max_hp = 5

var speed = 10.0
var attack_speed = 1
var armor = 0
var jump_speed = 4.5
var luck = 0.0
var mouse_sensitivity = .005
@onready var cam = $Camera3D


var attacking = [false,false]
var last_limbs = [null,null,null,null,null,null]


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
	if Input.is_action_just_pressed("esc"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed("k"):
		for child in get_tree().get_nodes_in_group("enemy"):
			child.queue_free()

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
	
	if Input.is_action_pressed("right_click") and !attacking[1]:
		attacking[1] = true

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
			node.get_child(0).get_node("attack_box").body_entered.connect(update_enemy_ui)

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
		if node.get_node("AnimationPlayer").current_animation != "attack" and get_node("attack_cooldown"+str(node.side)).is_stopped():
			node.get_node("AnimationPlayer").play(animString, .3)
			node.get_node("AnimationPlayer").advance(0)
			get_node("attack_cooldown"+str(node.side)).start(node.get_node("AnimationPlayer").get_animation(animString).length * node.attack_speed)
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
				node.get_node("AnimationPlayer").advance(node.get_node("AnimationPlayer").get_animation(animString).length/ 2 * node.attack_speed)

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
			set_animation($body/left_arm.get_child(0),"attack")
		if attacking[1]:
			set_animation($body/right_arm.get_child(0),"attack")

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
	limb_checker()

func _physics_process(delta: float) -> void:
	
	if global_position.y < -5:
		$ui/Control/health_bar.value = current_hp
		
		$ui/Control/health.text = "hp: " + str(current_hp)
		
		$ui/death_screen.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
	
	update_ui()
	attack()
	movement(delta)
	cheats()
	animation_states()
	
	move_and_slide()
	
	rigid_interaction()



func _on_hit_box_area_entered(area: Area3D) -> void:
	current_hp -= global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p)
	
	if current_hp <= 0:
		$ui/Control/health_bar.value = current_hp
		
		$ui/Control/health.text = "hp: " + str(current_hp)
		
		$ui/death_screen.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("limb") and global.hover_limb == null:
		if attacking[0] == true and attacking[1] == true and get_tree().get_node_count_in_group("enemy") > 0:
			pass
		else:
			global.hover_limb = body
			body.get_node("billboard").visible = true
	
	if body.is_in_group("enemy") and body != null:
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

func update_enemy_ui(body: Node3D) -> void:
	if body != null:
		$ui/Control/enemy.visible = true
		$ui/Control/enemy_hp.visible = true
		
		$ui/Control/enemy_hp.max_value = body.max_hp
		$ui/Control/enemy_hp.value = body.hp
		if body.special_type != "none":
			$ui/Control/enemy.text = body.get_node("body/head").get_child(0).special_type + " " + body.e_name
		else:
			$ui/Control/enemy.text = body.e_name


func _on_attack_cooldown_0_timeout() -> void:
	attacking[0] = false


func _on_attack_cooldown_1_timeout() -> void:
	attacking[1] = false
