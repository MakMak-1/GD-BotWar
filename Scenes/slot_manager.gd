extends Node2D

var card_manager_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_manager_reference = $"../CardManager"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func connect_signals(slot: Node2D):
	slot.connect("slot_entered", on_slot_entered)
	slot.connect("slot_exited", on_slot_exited)
	
func on_slot_entered(slot: Node2D, area: Node2D):
	card_manager_reference.set_entered_slot(slot)
	
func on_slot_exited(slot: Node2D, area: Node2D):
	card_manager_reference.set_entered_slot(null)

func disable_slots():
	$WeaponSlot.disabled = true
	$ShieldSlot.disabled = true
