extends CharacterBody3D

@export_category("Combat")
@export var damage = 1
@export var current_hp = 5
@export var max_hp = 5

var speed = 5.0
var jump_speed = 4.5
var mouse_sensitivity = .005
@onready var cam = $Camera3D

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
		$AnimationPlayer.play("attack")

func limb_checker():
	if $body/left_arm.get_child(0) != last_limbs[2]:
		if last_limbs != null:
			max_hp -= last_limbs[2].hp
		last_limbs[0] = $body/left_arm.get_child(0)


func _unhandled_input(event):
	# Handle vertical/horizontal camera rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		rotation.x = clamp(cam.rotation.x, deg_to_rad(-45), deg_to_rad(45))

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	movement(delta)
	cheats()
	attack()
	
	move_and_slide()


func _on_hit_box_area_entered(area: Area3D) -> void:
	current_hp -= area.get_parent().damage
	
