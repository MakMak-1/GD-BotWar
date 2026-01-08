extends Node2D

const stregth = {
	"ace": 1,
	"2": 2,
	"3": 3,
	"4": 4,
	"5": 5,
	"6": 6,
	"7": 7,
	"8": 8,
	"9": 9,
	"10": 10,
	"jack": 11,
	"queen": 12,
	"king": 13,
	"joker": 14
}

var player_hand_known: bool
var possible_cards: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hand_known = false
	var ranks = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "king", "queen"]
	var suits = ["clubs", "diamonds", "hearts", "spades"]
	
	for rank in ranks:
		for suit in suits:
			var card_name = rank + "_of_" + suit
			possible_cards.append(card_name)
	possible_cards.append("joker_black")
	possible_cards.append("joker_red")

func pick_attack_bot(hand: Array, player_weapon: Node2D, player_shield: Node2D):
	update_possible_cards(hand, player_weapon, player_shield)
	
	# pick weapon
	var player_shield_strength = stregth[player_shield.get_rank()]
	var curr_weapon = null
	
	for card in hand:
		if card.get_color() == "red" and not card.get_rank() == "joker":
			continue
		var card_strength = stregth[card.get_rank()]
		if player_shield_strength == 13:
			if card_strength == 14:
				curr_weapon = card
			else:
				continue
		
		if card_strength >= player_shield_strength and (curr_weapon == null or card_strength < stregth[curr_weapon.get_rank()]):
			curr_weapon = card
	
	# pick shield
	var curr_shield = null
	for card in hand:
		if card.get_color() == "black" or card.get_rank() == "joker":
			continue
		var card_strength = stregth[card.get_rank()]
		if curr_shield == null or card_strength < stregth[curr_shield.get_rank()]:
			curr_shield = card
	
	return [curr_weapon, curr_shield]

func pick_defence_bot(hand: Array):
	update_possible_cards(hand, null, null)
	
	# pick weapon
	var curr_weapon = null
	for card in hand:
		if card.get_color() == "red" and not card.get_rank() == "joker":
			continue
		var card_strength = stregth[card.get_rank()]
		if curr_weapon == null or card_strength < stregth[curr_weapon.get_rank()]:
			curr_weapon = card
	
	# pick shield
	var curr_shield = null
	for card in hand:
		if card.get_color() == "black" or card.get_rank() == "joker":
			continue
		var card_strength = stregth[card.get_rank()]
		if player_hand_known:
			if stronger_than_highest_weapon(card_strength) and (curr_shield == null or card_strength < stregth[curr_shield.get_rank()]):
				curr_shield = card
		elif curr_shield == null or card_strength > stregth[curr_shield.get_rank()]:
			curr_shield = card
	
	if player_hand_known and curr_shield == null:
		# pick min shield
		for card in hand:
			if card.get_color() == "black" or card.get_rank() == "joker":
				continue
			var card_strength = stregth[card.get_rank()]
			if curr_shield == null or card_strength < stregth[curr_shield.get_rank()]:
				curr_shield = card
	
	return [curr_weapon, curr_shield]

func update_possible_cards(computer_hand: Array, player_weapon: Node2D, player_shield: Node2D):
	var cards = []
	for card in computer_hand:
		cards.append(card)
	if player_weapon != null:
		cards.append(player_weapon)
	if player_shield != null:
		cards.append(player_shield)
	
	for card in cards:
		var card_name: String
		var rank = card.get_rank()
		var suit = card.get_suit()
		if rank != "joker":
			card_name = rank + "_of_" + suit
		else:
			card_name = rank + "_" + suit
		
		if card_name in possible_cards:
			possible_cards.erase(card_name)
	
	if possible_cards.size() <= 10:
		player_hand_known = true

func stronger_than_highest_weapon(card_strength: int):
	var strongest_weapon = 0
	for card in possible_cards:
		var rank = card.split("_")[0]
		var color: String
		if rank == "joker":
			color = card.split("_")[1]
		else:
			var suit = card.split("_")[2]
			if suit == "clubs" or suit == "spades":
				color = "black"
			else:
				color = "red"
		
		if color == "red" and not rank == "joker":
			continue
		
		var weapon_strength = stregth[rank]
		if weapon_strength > strongest_weapon:
			strongest_weapon = weapon_strength
			
	if card_strength > strongest_weapon:
		return true
	
	if card_strength == 13 and card_strength >= strongest_weapon:
		return true
	
	return false
