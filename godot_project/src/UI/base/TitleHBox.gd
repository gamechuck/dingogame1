tool
extends HBoxContainer

export(String) var text : String setget set_text, get_text
func set_text(value : String) -> void:
	text = value

	if has_node("Label"):
		$Label.text = text
func get_text() -> String:
	return text
#
#func _ready() -> void:
#	set_text(text)
