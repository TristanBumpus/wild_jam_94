extends Node3D

@export var start : Node3D

@export var dung_levels : Array[PackedScene]
@export var mount_lvl : Array[PackedScene]
@export var trans_lvl : Array[PackedScene]

@export var size = 5
@export var size_mount = 5
@export var size_dtm = 5

@export var enemies: Array[PackedScene]



func genocide():
	for child in $enemy_holder.get_children():
		child.queue_free()
		global.new_level = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start = get_child(0).get_node("door3")
	
	var leve = load("res://Levels/pool_test/dung_lvl_3.tscn").instantiate()
	
	get_tree().current_scene.add_child(leve)
	
	leve.global_position = start.global_position
	
	leve.global_position.y = 0
	
	start = leve.find_child("door")
	
	
	
	while size:
		
		var level = dung_levels.pick_random().instantiate()
		
		get_tree().current_scene.add_child(level)
		
		level.global_position = start.global_position
		
		level.global_position.y = 0
		
		start = level.find_child("door")
		
		size -= 1
	while size_dtm:
		
		var level = trans_lvl.pick_random().instantiate()
		
		get_tree().current_scene.add_child(level)
		
		level.global_position = start.global_position
		
		level.global_position.y = 0
		
		start = level.find_child("door")
		
		size_dtm -= 1
	
	
	while size_mount:
		
		var l = mount_lvl.pick_random().instantiate()
		
		get_tree().current_scene.add_child(l)
		
		l.global_position = start.global_position
		
		l.global_position.y = 0
		
		start = l.find_child("door")
		
		size_mount -= 1
	
	var level = load("res://Levels/pool_test/boss_room.tscn").instantiate()
	
	get_tree().current_scene.add_child(level)
	
	level.global_position = start.global_position
	
	level.global_position.y = 0
	
	start = level.find_child("door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
