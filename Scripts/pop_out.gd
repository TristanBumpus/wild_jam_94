extends Label3D

var ran
var ran2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ran = randi_range(-1,1)
	ran2 = randi_range(-1,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += .02
	position.z += ran * .02
	position.x += ran2 * .02



func _on_timer_timeout() -> void:
	queue_free()
