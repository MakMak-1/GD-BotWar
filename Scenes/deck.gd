extends Node2D

var deck: Array
var empty: bool
var prev_color: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ranks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "king", "queen"]
	var suits = ["clubs", "diamonds", "hearts", "spades"]
	
	for rank in ranks:
		for suit in suits:
			var card_name = rank + "_of_" + suit
			deck.append(card_name)
	deck.append("joker_black")
	deck.append("joker_red")
	
	empty = false
	prev_color = "red"

func draw_card():
	var card = deck.pick_random()
	while get_color(card) == prev_color:
		card = deck.pick_random()
	deck.erase(card)
	$"../DeckCardCounter".text = "{amount} left".format({"amount": deck.size()})
	if deck.size() == 0:
		empty = true
	
	if prev_color == "red":
		prev_color = "black"
	else:
		prev_color = "red"
	
	return card

func get_color(card: String):
	var rank: String = card.split("_")[0]
	var color: String
	
	if rank == "joker":
		color = card.split("_")[1]
	else:
		var suit: String = card.split("_")[2]
		if suit == "clubs" or suit == "spades":
			color = "black"
		else:
			color = "red"
	
	return color

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
