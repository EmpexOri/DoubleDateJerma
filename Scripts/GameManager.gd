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
	1: 5.0,
	2: 5.0
}

var success_counts = {
	1: 0,
	2: 0
}

var quotes = [
	"Great job!",
	"Keep going!",
	"You're on fire!",
	"Nice move!",
]

var voice_lines = [
	"res://SFX/FX/VoiceLines/great_job.wav",
	"res://SFX/FX/VoiceLines/keep_going.wav",
	"res://SFX/FX/VoiceLines/nice_move.wav",
	"res://SFX/FX/VoiceLines/youre_on_fire.wav",
]

@onready var player1_ui = $CanvasLayer/Player1UI
@onready var player2_ui = $CanvasLayer/Player2UI

@onready var correct_sound_player_1 = player1_ui.get_node("CorrectSoundPlayer")
@onready var wrong_sound_player_1 = player1_ui.get_node("WrongSoundPlayer")
@onready var correct_sound_player_2 = player2_ui.get_node("CorrectSoundPlayer")
@onready var wrong_sound_player_2 = player2_ui.get_node("WrongSoundPlayer")

@onready var middle_text_label = $CanvasLayer/MiddleTextLabel
@onready var voice_player = $VoicePlayer

var game_timer = GAME_TIME_LIMIT  # Game timer initialized to 201 seconds
var game_ended = false  # Flag to check if the game has ended

func _ready():
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

func handle_input(player, input_str):
	# Ignore inputs if the game's ended
	if game_ended:
		return
	
	# Ignore inputs if the player's timer has expired
	if timers[player] <= 0:
		return
	
	player_inputs[player].append(input_str)

	# Play sound for each input (correct or incorrect)
	if input_str == current_sequence[player][player_inputs[player].size() - 1]:
		play_sound(player, "correct")
	else:
		play_sound(player, "wrong")

	if player_inputs[player].size() == current_sequence[player].size():
		# Sequence complete, check if the entire sequence is correct
		if player_inputs[player] == current_sequence[player]:
			scores[player] += 10
			timers[player] += 2.5  # Bonus time
			success_counts[player] += 1

			var extra_length = int(success_counts[player] / 5)
			generate_new_sequence(SEQUENCE_LENGTH + extra_length, player)
			
			# Play correct sound after completing sequence
			play_sound(player, "correct")
			# Update the middle text and play voice line after completing sequence
			update_middle_text_and_voice_line()
		else:
			# Play wrong sound after completing sequence
			play_sound(player, "wrong")

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

	print("Game Over!")
	update_ui()  # Update the UI with final scores

	# Transition to Main Menu after a short delay
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func round_decimal(value: float, places: int = 1) -> float:
	var factor = pow(10, places)
	return round(value * factor) / factor
