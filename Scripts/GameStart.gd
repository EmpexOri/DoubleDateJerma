extends Node

# Preload your audio streams and target scene
@onready var sound_start = preload("res://SFX/FX/sfx_boot.mp3")
@onready var sound_delete = preload("res://SFX/FX/sfx_load.mp3")
@onready var boot_node = get_node_or_null("Boot")

var start_player : AudioStreamPlayer
var delete_player : AudioStreamPlayer

var skipped = false

func _ready():
	# Set up audio players
	start_player = AudioStreamPlayer.new()
	delete_player = AudioStreamPlayer.new()

	start_player.stream = sound_start
	delete_player.stream = sound_delete

	add_child(start_player)
	add_child(delete_player)

	# Play the start sound
	start_player.play()

	# Start timers asynchronously
	run_timers()

func run_timers() -> void:
	# Using async function to wait on timers
	await get_tree().create_timer(7.0).timeout
	if not skipped:
		_on_13_seconds()

	await get_tree().create_timer(6.0).timeout # 16s total (10 + 6)
	if not skipped:
		_on_16_seconds()

func _on_13_seconds():
	if boot_node:
		boot_node.queue_free()
	delete_player.play()

func _on_16_seconds():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"): # default ESC key in Godot
		skipped = true
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
