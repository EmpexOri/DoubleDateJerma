extends Control
@onready var start_button = $CanvasLayer/StartButton  
func _process(delta):
	start_button.grab_focus()
	if Input.is_action_just_pressed("ui_accept"):
		_on_start_button_pressed()

# Start button handler
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
