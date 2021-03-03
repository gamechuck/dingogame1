extends Node

signal locale_changed

const SUPPORTED_LOCALES := [ "en", "hr" ]
const DEFAULT_LOCALE := "en"
const LOCALE_NAMES := {
	"en": "English",
	"hr": "Hrvatski",
}
var current_locale := DEFAULT_LOCALE

# warning-ignore:unused_argument
func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("debug_cycle_locale"):
		var current_locale_idx := SUPPORTED_LOCALES.find(current_locale)
		var next_locale_idx := wrapi(current_locale_idx + 1, 0, SUPPORTED_LOCALES.size())
		set_locale(SUPPORTED_LOCALES[next_locale_idx])

func set_locale(v : String) -> void:
	if not SUPPORTED_LOCALES.has(v):
		push_warning("locale '" + v + "' not supported!")
		return

	current_locale = v
	TranslationServer.set_locale(current_locale)
	#DebugOverlay.update_locale_label(current_locale)
	#Keyboard.build_keyboard_for_locale(current_locale)

	emit_signal("locale_changed", current_locale)

func get_locale_name(locale : String) -> String:
	return LOCALE_NAMES.get(locale, "MISSING_LOCALE_NAME")
