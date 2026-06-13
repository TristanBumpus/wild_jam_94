extends CharacterBody3D

class_name Enemy

@export_category("Combat")
@export_enum("melee", ) var attack_type = 0
@export var hp = 1
@export var damage = 1
@export var hit_box : Area3D
@export var loot: Array[PackedScene] = []

@export var loot_chance : Array[int] = []

@export_category("Movement")
@export_enum("basic") var movement_type = 0
@export var speed = 1
@export var nav : NavigationAgent3D
@export var is_effected_by_gravity = true


var player: CharacterBody3D



func basic_movement():
	nav.target_position = player.global_position
	if nav.is_target_reachable():
		var flat_direction = Vector2(
			player.global_position.x - global_position.x,
			player.global_position.z - global_position.z
		)
		
		# 2. Calculate the target angle on the floor grid
		# Note: We use -flat_direction.y because Godot's 3D forward is -Z
		var target_angle = flat_direction.angle_to(Vector2.UP)
		
		# 3. Apply the smooth rotation ONLY to the Y-axis
		rotation.y = lerp_angle(rotation.y, target_angle, .05)
		var dir = (nav.get_next_path_position() - global_position).normalized()
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed

func melee_attack():
	if global_position.distance_to(player.global_position) < 2:
		$AnimationPlayer.play("melee_attack")



func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	#hit_box.connect("attacked", )

func _process(delta: float) -> void:
	if is_effected_by_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	if movement_type == 0:
		basic_movement()
	
	if attack_type == 0:
		melee_attack()
	
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	hp -= area.get_parent().damage
	
	if hp <= 0:
		var chance = randi_range(1,100)
		
		var times = 0
		
		for c in loot_chance:
			if chance <= c:
				break
			times += 1
		
		var l = loot[times].instantiate()
		l.global_position = global_position
		
		get_tree().current_scene.add_child(l)
		queue_free()
