extends Node2D

const HAND_SIZE: int = 10
const HAND_Y_POS: int = 710
const COMPUTER_HAND_Y_POS = 90
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

var dragged_card: Node2D
var screen_size: Vector2
var entered_slot: Node2D
var player_hand: Array
var computer_hand: Array
var curr_turn_state: String
var player_score: int
var computer_score: int
var computer_weapon: Node2D
var computer_shield: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	dragged_card = null
	entered_slot = null
	player_hand = []
	curr_turn_state = "p1"
	player_score = 0
	computer_score = 0
	draw_computer_hand()
	draw_missing_cards()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragged_card != null:
		dragged_card.position = Vector2(clamp(get_local_mouse_position().x, 0, screen_size.x), clamp(get_local_mouse_position().y, 0, screen_size.y))
	$"../PlayBotButton".disabled = not play_button_ready()
	$"../SkipTurnButton".disabled = not skip_button_ready()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			mouse_press()
		else:
			mouse_release()

func mouse_press():
	var card = get_clicked_card()
	if card != null and card.disabled == false:
		dragged_card = card
		dragged_card.z_index = 1

func mouse_release():
	if dragged_card != null:
		if entered_slot != null and entered_slot.objects_entered == 1:
			dragged_card.position = entered_slot.position
			dragged_card.z_index = -1
			player_hand.erase(dragged_card)
			update_cards_pos()
		else:
			dragged_card.z_index = 0
			if dragged_card in player_hand:
				card_move_to_pos(dragged_card, dragged_card.original_pos)
			else:
				player_hand.append(dragged_card)
				update_cards_pos()
		dragged_card = null
		entered_slot = null

func get_clicked_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		for obj in result:
			var node: Node2D = obj.collider.get_parent()
			if node.scene_file_path == "res://Scenes/card.tscn":
				return node
	return null

func set_entered_slot(slot: Node2D):
	entered_slot = slot

func add_to_player_hand(card: Node2D):
	card.position.y = HAND_Y_POS
	player_hand.append(card)

func add_to_computer_hand(card: Node2D):
	card.position.y = HAND_Y_POS
	computer_hand.append(card)

func update_cards_pos():
	var n: int = player_hand.size()
	var card_width = 100
	var card_margin = 10
	var player_hand_start_x = (screen_size.x - (card_width + card_margin) * n - card_margin) / 2 + card_width / 2
	for i in range(n):
		var card = player_hand[i]
		var new_pos = Vector2(player_hand_start_x + i * (card_width + card_margin), HAND_Y_POS)
		card.original_pos = new_pos
		card_move_to_pos(card, new_pos)

func update_cards_pos_computer():
	var n: int = computer_hand.size()
	var card_width = 100
	var card_margin = 10
	var computer_hand_start_x = (screen_size.x - (card_width + card_margin) * n - card_margin) / 2 + card_width / 2
	for i in range(n):
		var card = computer_hand[i]
		var new_pos = Vector2(computer_hand_start_x + i * (card_width + card_margin), COMPUTER_HAND_Y_POS)
		card.original_pos = new_pos
		card_move_to_pos(card, new_pos)

func card_move_to_pos(card, pos):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, 0.15)

func draw_missing_cards():
	var card_scene = preload("res://Scenes/card.tscn")
	var added_cards: Array = []
	for i in range(0, HAND_SIZE - player_hand.size()):
		if $"../Deck".empty:
			break
		var new_card = card_scene.instantiate()
		var card_name = $"../Deck".draw_card()
		new_card.change_to(card_name)
		
		$".".add_child(new_card)
		add_to_player_hand(new_card)
		added_cards.append(new_card)
	update_cards_pos()
	for card in added_cards:
		card.get_node("AnimationPlayer").play("card_flip")

func draw_computer_hand():
	var card_scene = preload("res://Scenes/card.tscn")
	var added_cards: Array = []
	for i in range(0, HAND_SIZE - computer_hand.size()):
		if $"../Deck".empty:
			break
		var new_card = card_scene.instantiate()
		var card_name = $"../Deck".draw_card()
		new_card.change_to(card_name)
		
		$".".add_child(new_card)
		new_card.disable()
		add_to_computer_hand(new_card)
		added_cards.append(new_card)
	update_cards_pos_computer()
	#for card in added_cards:
		#card.get_node("AnimationPlayer").play("card_flip")

func play_button_ready():
	var shield: Node2D = $"../SlotManager/ShieldSlot".played_card
	var weapon: Node2D = $"../SlotManager/WeaponSlot".played_card
	var ready: bool = shield != null and weapon != null and (player_hand.size() == HAND_SIZE - 2 or $"../Deck".deck.size() == 0)
	if curr_turn_state == "p2" and computer_shield != null:
		ready = ready and compare_strength($"../SlotManager/WeaponSlot".played_card, computer_shield) == 1
	return ready

func skip_button_ready():
	var shield: Node2D = $"../SlotManager/ShieldSlot".played_card
	var weapon: Node2D = $"../SlotManager/WeaponSlot".played_card
	return curr_turn_state == "p2" and shield == null and weapon == null and (player_hand.size() == HAND_SIZE or $"../Deck".deck.size() == 0)

func _on_play_bot_button_pressed() -> void:
	change_turn_state()

func _on_skip_turn_button_pressed() -> void:
	change_turn_state()

func change_turn_state():
	var player_weapon: Node2D
	var player_shield: Node2D
	var flag: bool = false
	
	if curr_turn_state == "p1":
		$"../SlotManager/WeaponSlot".disabled = true
		$"../SlotManager/ShieldSlot".disabled = true
		player_weapon = $"../SlotManager/WeaponSlot".played_card
		player_shield = $"../SlotManager/ShieldSlot".played_card
		player_weapon.disable()
		player_shield.disable()
		curr_turn_state = "c2"
		$"../Turn".text = "Turn: Computer offence"
		flag = true
	
	if curr_turn_state == "c2":
		var computer_bot: Array = $"../AI".pick_attack_bot(computer_hand, player_weapon, player_shield)
		computer_weapon = computer_bot[0]
		computer_shield = computer_bot[1]
		if computer_weapon == null or computer_shield == null:
			# computer skips
			$"../ComputerSkipLabel".visible = true
			increase_player_score()
			discard(player_weapon)
			discard(player_shield)
			player_weapon = null
			player_shield = null
			await sleep(1.5)
			draw_missing_cards()
			$"../ComputerSkipLabel".visible = false
		else:
			card_move_to_pos(computer_weapon, $"../ComputerWeaponSlot".position)
			card_move_to_pos(computer_shield, $"../ComputerShieldSlot".position)
			computer_weapon.get_node("AnimationPlayer").play("card_flip")
			computer_shield.get_node("AnimationPlayer").play("card_flip")
			computer_hand.erase(computer_weapon)
			computer_hand.erase(computer_shield)
			update_cards_pos_computer()
			
			await sleep(1.5)
			destroy_card(player_weapon)
			destroy_card(player_shield)
			player_weapon = null
			player_shield = null
			increase_computer_score()
			await sleep(1)
			discard(computer_weapon)
			discard(computer_shield)
			computer_weapon = null
			computer_shield = null
			await sleep(1)
			draw_computer_hand()
			draw_missing_cards()
		$"../Turn".text = "Turn: Computer defense"
		curr_turn_state = "c1"
		if not are_hands_playable() or player_score >= 10 or computer_score >= 10:
			get_winner()
			return
	
	if curr_turn_state == "c1":
		var computer_bot: Array = $"../AI".pick_defence_bot(computer_hand)
		computer_weapon = computer_bot[0]
		computer_shield = computer_bot[1]
		card_move_to_pos(computer_weapon, $"../ComputerWeaponSlot".position)
		card_move_to_pos(computer_shield, $"../ComputerShieldSlot".position)
		computer_weapon.get_node("AnimationPlayer").play("card_flip")
		computer_shield.get_node("AnimationPlayer").play("card_flip")
		computer_hand.erase(computer_weapon)
		computer_hand.erase(computer_shield)
		update_cards_pos_computer()
		$"../SlotManager/WeaponSlot".disabled = false
		$"../SlotManager/ShieldSlot".disabled = false
		$"../Turn".text = "Turn: Player1 offence"
		curr_turn_state = "p2"
		flag = true
	
	if curr_turn_state == "p2" and not flag:
		player_weapon = $"../SlotManager/WeaponSlot".played_card
		player_shield = $"../SlotManager/ShieldSlot".played_card
		if player_weapon == null or player_shield == null:
			# player skips
			increase_computer_score()
			discard(computer_weapon)
			discard(computer_shield)
			computer_weapon = null
			computer_weapon = null
			draw_computer_hand()
		else:
			$"../AI".update_possible_cards([], player_weapon, player_shield)
			destroy_card(computer_weapon)
			destroy_card(computer_shield)
			computer_weapon = null
			computer_shield = null
			increase_player_score()
			await sleep(1)
			discard(player_weapon)
			discard(player_shield)
			player_weapon = null
			player_shield = null
			draw_missing_cards()
			draw_computer_hand()
		$"../Turn".text = "Turn: Player1 defense"
		curr_turn_state = "p1"
		if not are_hands_playable() or player_score >= 10 or computer_score >= 10:
			get_winner()
			return

func sleep(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func compare_strength(card1: Node2D, card2: Node2D):
	var card1_strength = stregth[card1.get_rank()]
	var card2_strength = stregth[card2.get_rank()]
	
	if card2.get_rank() == "king":
		if card1.get_rank() == "joker":
			return 1
		else:
			return -1
	
	if card1_strength >= card2_strength:
		return 1
	return -1
	
func increase_player_score():
	player_score += 1
	$"../PlayerScore".text = "Score: {score}".format({"score": player_score})

func increase_computer_score():
	computer_score += 1
	$"../ComputerScore".text = "Score: {score}".format({"score": computer_score})
	
func discard(card: Node2D):
	card.get_node("AnimationPlayer").play("card_flip_back")
	await sleep(0.5)
	var new_position = Vector2(-500, card.position.y)
	card_move_to_pos(card, new_position)
	await sleep(0.5)
	card.queue_free()

func destroy_card(card: Node2D):
	card.get_node("AnimationPlayer").play("card_shrink")
	await sleep(0.5)
	card.queue_free()

func are_hands_playable():
	# player hand
	if player_hand.size() == 0:
		return false
		
	var shield_counter: int = 0
	var weapon_counter: int = 0
	for card in player_hand:
		if card.get_rank() == "joker":
			weapon_counter += 1
		else:
			if card.get_color() == "black":
				weapon_counter += 1
			else:
				shield_counter += 1
	if shield_counter == 0 or weapon_counter == 0:
		return false
	
	# computer hand
	if computer_hand.size() == 0:
		return false
	
	shield_counter = 0
	weapon_counter = 0
	for card in computer_hand:
		if card.get_rank() == "joker":
			weapon_counter += 1
		else:
			if card.get_color() == "black":
				weapon_counter += 1
			else:
				shield_counter += 1
	if shield_counter == 0 or weapon_counter == 0:
		return false
	
	return true

func get_winner():
	if player_score > computer_score:
		$"../WinScreen/GameResult".text = "You win!"
	elif player_score < computer_score:
		$"../WinScreen/GameResult".text = "You lose"
	else:
		$"../WinScreen/GameResult".text = "Tie!"
		
	for card in player_hand:
		card.disable()
	for card in computer_hand:
		card.get_node("AnimationPlayer").play("card_flip")
	$"../WinScreen".visible = true
	$"../WinScreen/TryAgainButton".disabled = false
