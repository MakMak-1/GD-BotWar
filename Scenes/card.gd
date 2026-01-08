extends Node2D

var original_pos: Vector2
var disabled: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_pos = self.position
	disabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_rank():
	var image_name = $CardSprite.texture.resource_path.split('/')[-1].split('.')[0]
	return image_name.split('_')[0]

func get_color():
	var image_name = $CardSprite.texture.resource_path.split('/')[-1].split('.')[0]
	if get_rank() != "joker":
		var suit = image_name.split('_')[2]
		if suit == "clubs" or suit == "spades":
			return "black"
		else:
			return "red"
	else:
		return image_name.split('_')[1]

func get_suit():
	var image_name = $CardSprite.texture.resource_path.split('/')[-1].split('.')[0]
	if get_rank() != "joker":
		return image_name.split('_')[2]
	else:
		return image_name.split('_')[1]

func change_to(card_name: String):
	var sprite_path = "res://Sprites/Cards/{card_name}.png".format({"card_name": card_name})
	$CardSprite.texture = load(sprite_path)
	
func disable():
	disabled = true

func enable():
	disabled = false
