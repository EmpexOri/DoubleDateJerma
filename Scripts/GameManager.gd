extends Node

const INPUT_OPTIONS = ["A", "B", "Y", "X"]
const DISPLAY_MAP = {
	"A": "res://Art/Arrows/ArrowDown.png",
	"B": "res://Art/Arrows/ArrowRight.png",
	"Y": "res://Art/Arrows/ArrowUp.png",
	"X": "res://Art/Arrows/ArrowLeft.png"
}
const SEQUENCE_LENGTH = 4
const MAX_SEQUENCE_LENGTH = 10  # Limit to 10 labels (0-9)
const GAME_TIME_LIMIT = 201.0  # 3 minutes and 21 seconds (in seconds)

var current_sequence = {
	1: [],
	2: []
}

var player_inputs = {
	1: [],
	2: []
}

var scores = {
	1: 0,
	2: 0
}

var timers = {
	1: 15.0,
	2: 15.0
}

var success_counts = {
	1: 0,
	2: 0
}

var combo_counts = {
	1: 0,
	2: 0
}

var combo_multipliers = {
	1: 1,
	2: 1
}

var quotes = [
	"Oh wow",
	"No way",
	"That's crazy",
	"Tell me more...",
	"That's so cool",
	"That can't be true",
	"You're kidding",
	"I'm just ordering another cocktail",
	"This lobster is amazing btw",
	"You did that all by yourself?",
]

var voice_lines = [
	"res://SFX/FX/VoiceLines/Response (oh wow)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (no way)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (that’s crazy)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (tell me more)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (that’s so cool)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (that can’t be true)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (you’re kidding)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (another cocktail)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (lobster)_01 (edited).wav",
	"res://SFX/FX/VoiceLines/Response (you did that all by yourself)_01 (edited).wav",
]

var ViviannaPositiveSprites = [
	"res://Art/Character/Vivianna/Vivianna.png",
	"res://Art/Character/Vivianna/ViviannaHappy.png",
	"res://Art/Character/Vivianna/ViviannaLove.png",
	"res://Art/Character/Vivianna/ViviannaWink.png"
]

var ViviannaNegativeSprites = [
	"res://Art/Character/Vivianna/Negatives/VivAnger.png",
	"res://Art/Character/Vivianna/Negatives/VivBored.png",
	"res://Art/Character/Vivianna/Negatives/VivSick.png",
	"res://Art/Character/Vivianna/Negatives/VivTears.png",
	"res://Art/Character/Vivianna/Negatives/VivUpset.png",
]

@onready var announcer_player = $AnnouncerPlayer
@onready var vivianna_sprite = $CanvasLayer/Vivianna

@onready var player1_ui = $CanvasLayer/Player1UI
@onready var player2_ui = $CanvasLayer/Player2UI

@onready var combo_label_1 = player1_ui.get_node("ComboLabel")
@onready var combo_label_2 = player2_ui.get_node("ComboLabel")

@onready var correct_sound_player_1 = player1_ui.get_node("CorrectSoundPlayer")
@onready var wrong_sound_player_1 = player1_ui.get_node("WrongSoundPlayer")
@onready var correct_sound_player_2 = player2_ui.get_node("CorrectSoundPlayer")
@onready var wrong_sound_player_2 = player2_ui.get_node("WrongSoundPlayer")

@onready var middle_text_label = $CanvasLayer/MiddleTextPanel/MiddleTextLabel
@onready var voice_player = $VoicePlayer

var game_timer = GAME_TIME_LIMIT  # Game timer initialized to 201 seconds
var game_ended = false  # Flag to check if the game has ended

func _ready():
	var music = get_node("CanvasLayer/Music")
	randomize()
	generate_new_sequence()
	update_ui()

func _process(delta):
	if game_ended:
		return  # Stop processing if the game has ended

	# Decrease the game timer by delta time
	game_timer -= delta
	timers[1] -= delta
	timers[2] -= delta

	update_ui()

	# Check if the game time limit is exceeded
	if game_timer <= 0:
		end_game()

	# Check if either player time runs out
	if timers[1] <= 0 or timers[2] <= 0:
		# Lock the time for the player who ran out of time
		if timers[1] <= 0:
			timers[1] = 0
		if timers[2] <= 0:
			timers[2] = 0

		# End the game immediately once one player runs out of time
		end_game()

func update_ui():
	update_player_ui(player1_ui, 1, player_inputs[1])
	update_player_ui(player2_ui, 2, player_inputs[2])

	player1_ui.get_node("TimerLabel").text = "Time: " + str(round_decimal(timers[1]))
	player1_ui.get_node("ScoreLabel").text = "Score: " + str(scores[1])

	player2_ui.get_node("TimerLabel").text = "Time: " + str(round_decimal(timers[2]))
	player2_ui.get_node("ScoreLabel").text = "Score: " + str(scores[2])
	
	combo_label_1.text = "Combo x" + str(combo_multipliers[1])
	combo_label_2.text = "Combo x" + str(combo_multipliers[2])
	
	# Visual feedback based on multiplier strength
	combo_label_1.modulate = get_combo_color(combo_multipliers[1])
	combo_label_2.modulate = get_combo_color(combo_multipliers[2])

func update_player_ui(ui_node: Node, player: int, inputs: Array):
	var sequence_box = ui_node.get_node("SequenceBox")
	var sequence = current_sequence[player]

	# Limit the sequence to MAX_SEQUENCE_LENGTH to avoid out-of-bounds errors
	var max_size = min(sequence.size(), MAX_SEQUENCE_LENGTH)

	for i in range(max_size):
		var texture_rect = sequence_box.get_child(i)

		if i < sequence.size():
			texture_rect.visible = true

			# Load and set the image for the arrow direction
			var arrow_texture = load(DISPLAY_MAP.get(sequence[i], sequence[i]))  # Load image for the direction
			texture_rect.texture = arrow_texture

			# Color the texture depending on whether the input matches
			if i < inputs.size():
				if inputs[i] == sequence[i]:
					texture_rect.modulate = Color(0.4, 0.6, 1.0)  # Correct (blue)
				else:
					texture_rect.modulate = Color(1.0, 0.2, 0.2)  # Wrong (red)
			else:
				texture_rect.modulate = Color(1, 1, 1)  # Default
		else:
			texture_rect.visible = false

func _input(event):
	# If the game has ended, prevent further inputs from both players
	if game_ended:
		return

	# Player 1 Inputs
	if Input.is_action_just_pressed("PlayerDPad_A"):
		handle_input(1, "A")
	elif Input.is_action_just_pressed("PlayerDPad_B"):
		handle_input(1, "B")
	elif Input.is_action_just_pressed("PlayerDPad_Y"):
		handle_input(1, "Y")
	elif Input.is_action_just_pressed("PlayerDPad_X"):
		handle_input(1, "X")
	
	# Player 2 Inputs
	if Input.is_action_just_pressed("PlayerFButton_A"):
		handle_input(2, "A")
	elif Input.is_action_just_pressed("PlayerFButton_B"):
		handle_input(2, "B")
	elif Input.is_action_just_pressed("PlayerFButton_Y"):
		handle_input(2, "Y")
	elif Input.is_action_just_pressed("PlayerFButton_X"):
		handle_input(2, "X")
		
	# Secret button for Player 1
	if Input.is_action_just_pressed("SecretButton"):
		trigger_secret(1)
		player_inputs[1].clear()

func handle_input(player, input_str):
	# Ignore inputs if the game's ended
	if game_ended:
		return
	
	# Ignore inputs if the player's timer has expired
	if timers[player] <= 0:
		return
	
	# Append current input
	player_inputs[player].append(input_str)

	# Existing correctness check...
	var current_index = player_inputs[player].size() - 1
	if input_str == current_sequence[player][current_index]:
		play_sound(player, "correct")
	else:
		fail_sequence(player)
		return

	if player_inputs[player].size() == current_sequence[player].size():
		# Increase combo count
		combo_counts[player] += 1

		var prev_multiplier = combo_multipliers[player]

		# Update combo multiplier based on streak
		if combo_counts[player] >= 9:
			combo_multipliers[player] = 4
		elif combo_counts[player] >= 6:
			combo_multipliers[player] = 3
		elif combo_counts[player] >= 3:
			combo_multipliers[player] = 2
		else:
			combo_multipliers[player] = 1

		# If the multiplier increased, play a voice line
		if combo_multipliers[player] > prev_multiplier:
			play_combo_voice_line(player)

		# Apply score with multiplier
		scores[player] += 10 * combo_multipliers[player]
		timers[player] += 2.5  # Bonus time
		success_counts[player] += 1

		# Generate next sequence with length increase
		var extra_length = int(success_counts[player] / 5)
		generate_new_sequence(SEQUENCE_LENGTH + extra_length, player)

		play_sound(player, "correct")
		update_vivianna_sprite(true)
		update_middle_text_and_voice_line()
		
		player_inputs[player].clear()
		update_ui()

func play_sound(player, result):
	if player == 1:
		if result == "correct":
			if not correct_sound_player_1.playing:
				correct_sound_player_1.play()
		elif result == "wrong":
			if not wrong_sound_player_1.playing:
				wrong_sound_player_1.play()
	elif player == 2:
		if result == "correct":
			if not correct_sound_player_2.playing:
				correct_sound_player_2.play()
		elif result == "wrong":
			if not wrong_sound_player_2.playing:
				wrong_sound_player_2.play()

func update_middle_text_and_voice_line():
	# Randomly select a quote and corresponding voice line
	var random_index = randi() % quotes.size()
	var random_quote = quotes[random_index]
	var voice_line = voice_lines[random_index]

	# Update the label in the middle of the screen with the quote
	middle_text_label.text = random_quote

	# Load the corresponding voice line dynamically
	if GlobalSettings.date_voice_lines_enabled:
		var voice_stream = load(voice_line)
		voice_player.stream = voice_stream
		voice_player.play()

func generate_new_sequence(length := SEQUENCE_LENGTH, player : int = -1):
	if player != -1:
		# Update sequence for a specific player
		current_sequence[player] = []
		for i in range(min(length, MAX_SEQUENCE_LENGTH)):  # Ensure sequence length does not exceed max
			current_sequence[player].append(INPUT_OPTIONS[randi() % INPUT_OPTIONS.size()])
	else:
		# Generate for both players (used on game start)
		for p in [1, 2]:
			current_sequence[p] = []
			for i in range(min(length, MAX_SEQUENCE_LENGTH)):  # Ensure sequence length does not exceed max
				current_sequence[p].append(INPUT_OPTIONS[randi() % INPUT_OPTIONS.size()])

func end_game():
	game_ended = true  # Set the flag to true, preventing further inputs

	# Award score based on remaining time
	if timers[1] > 0:
		scores[1] += int(timers[1] * 10)
	if timers[2] > 0:
		scores[2] += int(timers[2] * 10)

	# Add the scores to the top scores list
	ScoresManager.add_score(1, scores[1])
	ScoresManager.add_score(2, scores[2])
	ScoresManager.current_score_player_1 = scores[1]
	ScoresManager.current_score_player_2 = scores[2]

	print("Game Over!")
	update_ui()  # Update the UI with final scores

	# Transition to Main Menu after a short delay
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Scenes/EndScene.tscn")
	
func get_combo_color(multiplier: int) -> Color:
	match multiplier:
		1: return Color(1, 1, 1)
		2: return Color(1, 0.8, 0.2)
		3: return Color(1, 0.5, 0.1)
		4: return Color(1, 0.2, 0.1)
		_: return Color(1, 1, 1)
		
func play_combo_voice_line(player):
	# Randomly select a combo voice line
	var combo_voice_lines = [
		"res://SFX/FX/Announcer/doublekill.mp3",
		"res://SFX/FX/Announcer/hillcontrolled.mp3",
		"res://SFX/FX/Announcer/killtacular.mp3",
		"res://SFX/FX/Announcer/killfrenzy.mp3",
		"res://SFX/FX/Announcer/Killimanjaro.mp3",
		"res://SFX/FX/Announcer/killtrocity.mp3",
		"res://SFX/FX/Announcer/Bamm, nice.mp3"
	]

	var random_index = randi() % combo_voice_lines.size()
	var voice_line = combo_voice_lines[random_index]

	# Load the corresponding voice line dynamically
	var voice_stream = load(voice_line)
	announcer_player.stream = voice_stream
	announcer_player.play()
	
func update_vivianna_sprite(success: bool):
	var sprite_list = ViviannaPositiveSprites if success else ViviannaNegativeSprites
	var random_index = randi() % sprite_list.size()
	var sprite_path = sprite_list[random_index]

	var sprite_texture = load(sprite_path)
	vivianna_sprite.texture = sprite_texture
	
func fail_sequence(player):
	# Play the wrong sound
	play_sound(player, "wrong")
	
	# Update Vivianna sprite to negative reaction
	update_vivianna_sprite(false)
	
	# Reset combo for player
	combo_counts[player] = 0
	combo_multipliers[player] = 1
	
	# Clear inputs immediately to block further input until reset
	player_inputs[player].clear()
	update_ui()
	
	# Wait 0.5 seconds before generating new sequence
	await get_tree().create_timer(0.0).timeout
	
	# Generate a new sequence of default length (or adjusted length)
	var extra_length = int(success_counts[player] / 5)
	generate_new_sequence(SEQUENCE_LENGTH + extra_length, player)
	update_ui()

func round_decimal(value: float, places: int = 1) -> float:
	var factor = pow(10, places)
	return round(value * factor) / factor

func trigger_secret(player):
	var music = get_node("CanvasLayer/Music")
	if music:
		music.stop()
		music.stream = load("res://SFX/OST/M@GICALCURE! LOVE SHOT!.mp3")
		music.play()
	else:
		print("Music node not found")
