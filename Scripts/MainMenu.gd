extends Control

@onready var player_1_score_label = $CanvasLayer/Player1/Player1ScoreLabel
@onready var player_2_score_label = $CanvasLayer/Player2/Player2ScoreLabel

func _ready():
	display_top_scores()

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

# Start button handler
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Intermission.tscn")

# Tutorial button handler
func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")

# Credits button handler
func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

# Exit button handler
func _on_exit_button_pressed() -> void:
	get_tree().quit()
