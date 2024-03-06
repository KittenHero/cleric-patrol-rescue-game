extends Resource
class_name ButtonTextureMapping

@export var button: InputEvent
@export var texture: Texture2D

func _to_string():
	return '%s: %s - %s' % [get_class(), button, texture]
