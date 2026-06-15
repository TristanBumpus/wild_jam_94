extends CharacterBody3D

@export_category("Combat")
@export var damage = 1
@export var current_hp = 5
@export var max_hp = 5

var speed = 5.0
var attack_speed = 1
var armor = 0
var jump_speed = 4.5
var luck = 0.0
var mouse_sensitivity = .005
@onready var cam = $Camera3D


var attacking = [false,false]
var last_limbs = [null,null,null,null,null,null]



func cheats():
	if Input.is_action_just_pressed("esc"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func movement(delta):
	
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
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func attack():
	if Input.is_action_just_pressed("left_click"):
		attacking[0] = true
	if Input.is_action_just_pressed("right_click"):
		attacking[1] = true

func limb_to_check(node,index):
	if node.get_child(0) != last_limbs[index]:
		if last_limbs[index] != null:
			max_hp -= last_limbs[index].hp
			speed -= last_limbs[index].speed
			armor -= last_limbs[index].armor
			luck -= last_limbs[index].luck
		
		last_limbs[index] = node.get_child(0)
		max_hp += node.get_child(0).hp
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

func set_animation(node:Node3D,animString:String):
	if animString == "attack":
		if node.get_node("AnimationPlayer").current_animation != "attack":
			node.get_node("AnimationPlayer").play(animString, .3)
			node.get_node("AnimationPlayer").advance(0)
			attacking[node.side] = false
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
				node.get_node("AnimationPlayer").advance(node.get_node("AnimationPlayer").get_animation(animString).length/ 2)

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
	#$ui/Control/health.text = "HP: " + str(current_hp)
	
	if $ui/Control/health_bar.value != current_hp:
		var t = create_tween()
		t.tween_property($ui/Control/health_bar,"value",current_hp,.2)
		#$ui/Control/health_bar.value += snapped(((current_hp - $ui/Control/health_bar.value)/.01),.01)
	
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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	limb_checker()

func _physics_process(delta: float) -> void:
	
	update_ui()
	
	movement(delta)
	cheats()
	attack()
	animation_states()
	
	move_and_slide()
	
	rigid_interaction()



func _on_hit_box_area_entered(area: Area3D) -> void:
	current_hp -= global.damage_calc(area.get_parent().damage,armor,area.get_parent().armor_p)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("limb"):
		body.get_node("billboard").visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("limb"):
		body.get_node("billboard").visible = false
