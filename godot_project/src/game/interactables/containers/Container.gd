class_name classContainer
extends classInteractable

# valid animation names:
#   empty
#   contains_character
#   contains_item

################################################################################
## PUBLIC VARIABLES
var contained_character = null
var last_removed_character = null

var item_amount_initial := 0 setget set_item_amount_initial
func set_item_amount_initial(v : int) -> void:
	item_amount_initial = v
	for i in v:
		push_item(classItem.new())

func get_sprite_offset() -> Vector2:
	return _animated_sprite.offset

################################################################################
## PRIVATE VARIABLES
export var _contained_item_count_max := 3
export var _can_contain_items := true
export var _can_contain_characters := false
export var _charchter_position_offset := Vector2.ZERO

export var _sfx_character_enter : AudioStream
export var _sfx_character_exit : AudioStream
export var _enter_noise := 2.0

var _contained_items := []

onready var _sfx := $SFX

################################################################################
## GODOT CALLBACKS
func _ready():
	add_to_group("containers")
	_update_sprite()

################################################################################
## PUBLIC FUNCTIONS
func remove_all_items() -> void:
	while _contained_items.size() > 0:
		pop_item()
	interactable = true

func push_item(item : classItem) -> void:
	if _contained_items.size() >= _contained_item_count_max:
		push_warning("Container " + name + " limit reached; not pushing item")
		return
	interactable = false
	_contained_items.append(item)
	_update_sprite()

func pop_item() -> classItem:
	if _contained_items.size() == 0:
		push_warning("Container " + name + " is empty; not popping item")
		return null

	var item = _contained_items.pop_back()
	_update_sprite()
	if _contained_items.size() < 1 and contained_character == null:
		interactable = true
	return item

func push_character(character : Node2D) -> void:
	if not _can_contain_characters:
		push_warning("Container " + name + " cannot contain characters!")
		return

	if contained_character:
		push_warning("Container " + name + " already has character; can't push!")
		return

	if _can_contain_items and _contained_items.size() > 0:
		return

	contained_character = character
	character.is_in_container = true
	character.container_enter_position = character.global_position
	# Added a small offset cause of special attack and render sorting
	character.global_position = global_position + _charchter_position_offset
	character.get_node("AnimatedSprite").hide()
	character.container = self
	_play_stream(_sfx_character_enter)
	_update_sprite()
	emit_signal("audio_source_spawn_requested", self, self.global_position,  { "noise": _enter_noise, "type" : Global.SOUND_SOURCE_TYPE.INTERACTION })

func pop_character() -> Node2D:
	if not contained_character:
		push_warning("Container " + name + " has no character; can't pop!")
		return null

	var character : Node2D = contained_character
	contained_character = null
	last_removed_character = character

	character.is_in_container = false
	character.global_position = character.container_enter_position
	character.get_node("AnimatedSprite").show()
	character.container = null
	_play_stream(_sfx_character_exit)
	_update_sprite()

	if _contained_items.size() < 1 and contained_character == null:
		interactable = true
	return character

func eject_character() -> void:
	if not contained_character:
		push_warning("Container " + name + " has no character; can't pop!")
		return

	var character : Node2D = contained_character
	contained_character = null
	last_removed_character = character

	character.is_in_container = false
	character.global_position = character.container_enter_position
	character.get_node("AnimatedSprite").show()
	character.container = null
	_play_stream(_sfx_character_exit)
	_update_sprite()

# TODO: (karlo) rename to has_anything()
func has_item() -> bool:
	if _can_contain_items and _contained_items.size() > 0:
		return true
	if _can_contain_characters and contained_character:
		return true
	return false

func has_character() -> bool:
	if _can_contain_characters and contained_character:
		return true
	return false

func is_empty() -> bool:
 return _contained_items.size()	== 0

func is_full() -> bool:
	if _can_contain_items and _contained_items.size() == _contained_item_count_max:
		return true
	if _can_contain_characters and contained_character:
		return true
	return false

func interact(interactor : Node2D) -> void:
	if interactor.is_in_group("players"):
		if _can_contain_characters:
			if contained_character:
				eject_character()
			else:
				push_character(interactor)
#	elif interactor.is_in_group("npcs"):
#		push_item(interactor.pop_item())
	pass

################################################################################
## PRIVATE FUNCTIONS
func _update_sprite() -> void:
	if _can_contain_characters and contained_character:
		_animated_sprite.play("contains_character")
	elif _can_contain_items and _contained_items.size() > 0:
		_animated_sprite.stop()
		_animated_sprite.animation = "contains_item"
		_animated_sprite.frame = _contained_items.size() - 1
	else:
		_animated_sprite.play("empty")

func _play_stream(stream : AudioStream) -> void:
	if not stream:
		return

	_sfx.stream = stream
	_sfx.play()
