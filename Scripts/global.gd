extends Node

var difficulty = 100
var new_level = false
var choice_active = false
var hover_limb = null

var all_legs = ["res://Entitites/limbs/kobold/kobold_leg.tscn","res://Entitites/limbs/spider/spider_legs.tscn","res://Entitites/limbs/turtle/turtle_leg.tscn"]
var all_torsos = ["res://Entitites/limbs/kobold/kobold_body.tscn","res://Entitites/limbs/spider/spider_body.tscn","res://Entitites/limbs/turtle/turtle_body.tscn"]
var all_heads = ["res://Entitites/limbs/kobold/kobold_head.tscn","res://Entitites/limbs/spider/spider_head.tscn","res://Entitites/limbs/turtle/turtle_head.tscn"]
var all_arms = ["res://Entitites/limbs/kobold/kobold_arm.tscn","res://Entitites/limbs/spider/spider_legs.tscn","res://Entitites/limbs/turtle/turtle_arm.tscn"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 60


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func damage_calc(dam,armor,armor_p):
	if armor - armor_p > 0:
		return snapped(dam * (1 - (armor - armor_p)/100),.01)
	else:
		return dam
