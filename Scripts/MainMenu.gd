extends Control

@onready var player_1_score_label = $CanvasLayer/Player1/Player1ScoreLabel
@onready var player_2_score_label = $CanvasLayer/Player2/Player2ScoreLabel

@onready var start_button = $CanvasLayer/StartButton
@onready var credits_button = $CanvasLayer/StartButton3
@onready var exit_button = $CanvasLayer/StartButton4

@onready var toggle = $CanvasLayer/DateVoiceToggle

var buttons = []
var selected_index = 0

func _ready():
	buttons = [start_button, credits_button, exit_button, toggle]
	display_top_scores()
	_update_button_focus()

func display_top_scores():
	# Display top 10 scores for Player 1
	if ScoresManager.top_scores_player_1.size() > 0:
		player_1_score_label.text = "Top 10 Scores (Player 1):\n"
		for i in range(min(ScoresManager.top_scores_player_1.size(), 10)):
			player_1_score_label.text += str(i + 1) + ". " + str(ScoresManager.top_scores_player_1[i]) + "\n"
	else:
		player_1_score_label.text = ""

	# Display top 10 scores for Player 2
	if ScoresManager.top_scores_player_2.size() > 0:
		player_2_score_label.text = "Top 10 Scores (Player 2):\n"
		for i in range(min(ScoresManager.top_scores_player_2.size(), 10)):
			player_2_score_label.text += str(i + 1) + ". " + str(ScoresManager.top_scores_player_2[i]) + "\n"
	else:
		player_2_score_label.text = ""

func _process(delta):
	# Check for navigation input
	if Input.is_action_just_pressed("ui_down"):
		_selected_next()
	elif Input.is_action_just_pressed("ui_up"):
		_selected_previous()
	elif Input.is_action_just_pressed("ui_accept"):
		_activate_selected()

func _selected_next():
	selected_index += 1
	if selected_index >= buttons.size():
		selected_index = 0
	_update_button_focus()

func _selected_previous():
	selected_index -= 1
	if selected_index < 0:
		selected_index = buttons.size() - 1
	_update_button_focus()

func _update_button_focus():
	for i in range(buttons.size()):
		if i == selected_index:
			buttons[i].grab_focus()  # visually select this button
		else:
			# Optionally, do something to "unhighlight" other buttons if needed
			pass

func _activate_selected():
	match selected_index:
		0:
			_on_start_button_pressed()
		1:
			_on_credits_button_pressed()
		2:
			_on_exit_button_pressed()

# Existing button pressed handlers
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Intermission.tscn")

func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_DateVoiceToggle_toggled(button_pressed: bool) -> void:
	GlobalSettings.date_voice_lines_enabled = button_pressed
	print("Date Voice Lines Enabled:", button_pressed)
