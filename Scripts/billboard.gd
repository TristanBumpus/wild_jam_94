extends CanvasLayer



@export var interactible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$interactible.visible = interactible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
