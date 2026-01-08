extends Node2D

signal slot_entered
signal slot_exited
var objects_entered: int
var played_card: Node2D
var disabled: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.get_parent().connect_signals(self)
	objects_entered = 0
	played_card = null
	disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	objects_entered += 1
	var card = area.get_parent()
	if not disabled and card.get_color() == "red" and card.get_rank() != "joker":
		emit_signal('slot_entered', self, area)
		if objects_entered == 1:
			played_card = card


func _on_area_2d_area_exited(area: Area2D) -> void:
	objects_entered -= 1
	emit_signal('slot_exited', self, area)
	if objects_entered == 0:
		played_card = null
