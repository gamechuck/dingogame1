tool
extends VBoxContainer
class_name classSection

export(String) var text : String setget set_text, get_text
func set_text(value : String) -> void:
	text = value
	$HBoxContainer/Label.text = text
func get_text() -> String:
	return text

export(bool) var has_visible_header : bool = true setget set_has_visible_header
func set_has_visible_header(value : bool) -> void:
	has_visible_header = value
	$HBoxContainer.visible = value
	if has_visible_header:
		set("custom_constants/separation", 16)
	else:
		set("custom_constants/separation", 0)

func update_section():
	for child in get_children():
		if child.has_method("update_setting"):
			child.update_setting()
		# Unfortunately we can't check here if the child is a classSection
		# due to circular referencing...
		elif child.has_method("update_section"):
			child.update_section()
