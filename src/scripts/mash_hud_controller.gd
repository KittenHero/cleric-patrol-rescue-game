extends Control

@onready var button: TextureRect = %button
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = %ProgressBar

@export var max_value: int = 30:
	set(val):
		max_value = val
		progress_bar.max_value = val
@export var value: float = 0:
	set(val):
		value = val
		progress_bar.value = val
@export var depletion_percent_per_sec: float = 10.0
@export var depletion_delay: float = 0.8   
var time: float = 0.0

signal complete();

var device_id = -1

func _ready():
	progress_bar.max_value = max_value
	progress_bar.value = value
	anim.play('mash')
	
	var devices = Input.get_connected_joypads()
	if not devices.is_empty():
		device_id = devices.front()
	Input.joy_connection_changed.connect(update_gamepad_connection)
	button.texture = get_action_prompt('interact').texture

func update_gamepad_connection(device: int, connected: bool):
	if connected:
		device_id = device
	else:
		device_id = -1
	button.texture = get_action_prompt('interact').texture

func get_action_prompt(action_name: StringName) -> ButtonTextureMapping:
	# TODO: set up mapping, gamepad detection, & this function as autoload
	var mapping: Array[ButtonTextureMapping] = [
		preload("res://resources/button_prompts/gamepad_a.tres"),
		preload("res://resources/button_prompts/space.tres")
	]
	for action in InputMap.action_get_events(action_name):
		if action is InputEventKey and device_id == -1:
			return mapping.filter(func(a): return a.button is InputEventKey and a.button.physical_keycode == action.physical_keycode).front()
		if action is InputEventJoypadButton and device_id != -1:
			return mapping.filter(func(a): return a.button is InputEventJoypadButton and a.button.button_index == action.button_index).front()
	return null
	
func _input(event):
	if event.is_action_pressed('interact') and value < max_value:
		time = 0
		await (
			create_tween()
			.tween_property(self, "value", value + 1, 0.075)
			.finished
		)
		time = 0
		if value >= max_value:
			value = 0
			complete.emit()

func _process(delta):
	if time >= depletion_delay:
		value = max(0, value - depletion_percent_per_sec * max_value * 0.01 * delta)
	time += delta
