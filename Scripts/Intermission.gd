extends CanvasLayer

@onready var title_label = $TitleLabel
@onready var player1_label = $Player1Controls
@onready var player2_label = $Player2Controls
@onready var countdown_label = $CountdownLabel

const COUNTDOWN_START := 10
var current_count := COUNTDOWN_START

# Load your custom font
@onready var base_font: Font = preload("res://Art/04B_08__.TTF")

func _ready():
	title_label.text = "Get Ready For Your Double Date"
	player1_label.text = get_player1_controls()
	player2_label.text = get_player2_controls()
	
	# Apply font to all labels
	title_label.add_theme_font_override("font", base_font)
	player1_label.add_theme_font_override("font", base_font)
	player2_label.add_theme_font_override("font", base_font)
	countdown_label.add_theme_font_override("font", base_font)

	update_countdown()
	start_countdown()

func start_countdown():
	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	add_child(countdown_timer)
	countdown_timer.timeout.connect(_on_countdown_tick)
	countdown_timer.start()

func _on_countdown_tick():
	current_count -= 1
	if current_count >= 0:
		update_countdown()
	else:
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func update_countdown():
	countdown_label.text = str(current_count)

func get_player1_controls() -> String:
	return """Player 1 (Left Side): D-Pad
↑ = Up
↓ = Down
← = Left
→ = Right"""

func get_player2_controls() -> String:
	return """Player 2 (Right Side): Face Buttons
Y = Up
A = Down
X = Left
B = Right"""
