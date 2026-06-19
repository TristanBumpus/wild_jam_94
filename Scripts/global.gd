extends Node

var difficulty = 100
var new_level = false
var choice_active = false
var hover_limb = null

var all_legs = ["res://Entitites/limbs/kobold/kobold_leg.tscn","res://Entitites/limbs/spider/spider_legs.tscn","res://Entitites/limbs/turtle/turtle_leg.tscn"]
var all_torsos = ["res://Entitites/limbs/kobold/kobold_body.tscn","res://Entitites/limbs/spider/spider_body.tscn","res://Entitites/limbs/turtle/turtle_body.tscn"]
var all_heads = ["res://Entitites/limbs/kobold/kobold_head.tscn","res://Entitites/limbs/spider/spider_head.tscn","res://Entitites/limbs/turtle/turtle_head.tscn"]
var all_arms = ["res://Entitites/limbs/kobold/kobold_arm.tscn","res://Entitites/limbs/spider/spider_legs.tscn","res://Entitites/limbs/turtle/turtle_arm.tscn"]

var sound_effects = preload("res://Entitites/effects/sound_effects.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Engine.max_fps = 60
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(Engine.get_frames_per_second())
	pass



func damage_calc(dam,armor,armor_p):
	if armor - armor_p > 0:
		return snapped(dam * (1 - (armor - armor_p)/100),.01)
	else:
		return snapped(dam,.01)

func play_sound(sound:String, pos, db = 0):
	var effect = sound_effects.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = pos
	effect.stream = load(sound)
	effect.volume_db = db
	effect.pitch_scale = randf_range(.8,1.2)
	effect.play()
