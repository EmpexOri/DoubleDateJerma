extends Node2D

var endings = [
	"Anyway, I should get going. Thanks again for dinner, the food was amazing. You guys are really fun, you both have such a unique energy.",
	"Well it was super fun hanging out, thank you guys so much for paying for dinner! We’ll have to do it again some time.",
	"This was such a fun night, thank you both for being so generous. It was great getting to know you both, we should do it again in a couple months."
]

var player1_score_label : Label
var player2_score_label : Label
var middle_text_label : Label
var event_label : Label

var words = []
var current_word_index = 0
var word_timer : Timer
var delay_timer : Timer

var _showing_scores = false
var _showing_winner = false

var current_scores = {
	"player1": 0,
	"player2": 0
}

func _ready():
	var game_manager = $GameManager
	var canvas_layer = game_manager.get_node("CanvasLayer")

	player1_score_label = canvas_layer.get_node("Player1UI/ScoreLabel")
	player2_score_label = canvas_layer.get_node("Player2UI/ScoreLabel")
	middle_text_label = canvas_layer.get_node("MiddleTextPanel/MiddleTextLabel")
	event_label = canvas_layer.get_node("EventLabel")

	event_label.text = ""

	# Get current scores fresh from ScoresManager singleton
	current_scores["player1"] = ScoresManager.current_score_player_1
	current_scores["player2"] = ScoresManager.current_score_player_2

	# Timer for word printing
	word_timer = Timer.new()
	word_timer.wait_time = 0.075
	word_timer.one_shot = false
	word_timer.connect("timeout", Callable(self, "_on_word_timer_timeout"))
	add_child(word_timer)

	# Timer for delays between stages (scores & winner)
	delay_timer = Timer.new()
	delay_timer.one_shot = true
	delay_timer.connect("timeout", Callable(self, "_on_delay_timer_timeout"))
	add_child(delay_timer)

	start_endgame_sequence()

func start_endgame_sequence() -> void:
	_endgame_sequence()

func _endgame_sequence() -> void:
	var ending_text = endings[randi() % endings.size()]
	words = ending_text.split(" ")
	current_word_index = 0
	middle_text_label.text = ""
	player1_score_label.text = ""
	player2_score_label.text = ""
	event_label.text = ""

	word_timer.start()

func _on_word_timer_timeout() -> void:
	if current_word_index < words.size():
		middle_text_label.text += words[current_word_index] + " "
		current_word_index += 1
	else:
		word_timer.stop()
		# Start delay timer for showing scores after 3 seconds
		delay_timer.wait_time = 3.0
		delay_timer.start()

		_showing_scores = true

var _showing_done = false

func _on_delay_timer_timeout() -> void:
	if _showing_scores:
		# Show scores
		player1_score_label.text = "Player 1 Score: %d" % current_scores["player1"]
		player2_score_label.text = "Player 2 Score: %d" % current_scores["player2"]

		# Setup next delay before showing winner
		delay_timer.wait_time = 5.0
		delay_timer.start()

		_showing_scores = false
		_showing_winner = true

	elif _showing_winner:
		# Show winner text
		if current_scores["player1"] > current_scores["player2"]:
			event_label.text = "Winner: Player 1!"
		elif current_scores["player2"] > current_scores["player1"]:
			event_label.text = "Winner: Player 2!"
		else:
			event_label.text = "It's a tie!"

		_showing_winner = false

		# Start final delay before switching to main menu
		delay_timer.wait_time = 5.0
		delay_timer.start()
		_showing_done = true

	elif _showing_done:
		# After final wait, switch scene back to main menu
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
