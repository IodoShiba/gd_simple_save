@tool
extends EditorPlugin

const Consts := preload("res://addons/gd_simple_save/internals/consts.gd")
const Encoder := preload("res://addons/gd_simple_save/internals/encoder.gd")

const SETTING_NAME_SAVE = Consts.SETTING_NAME_SAVE
const SETTING_VALUE_SAVE_PATH = Consts.SETTING_VALUE_SAVE_PATH
const SETTING_VALUE_SAVE_EXTENSION = Consts.SETTING_VALUE_SAVE_EXTENSION


func _enter_tree() -> void:
	_require_custom_project_setting(
		SETTING_NAME_SAVE + SETTING_VALUE_SAVE_PATH,
		"user://saves/",
		TYPE_STRING,
		PROPERTY_HINT_GLOBAL_DIR
		)
	
	_require_custom_project_setting(
		SETTING_NAME_SAVE + SETTING_VALUE_SAVE_EXTENSION,
		".gamesave",
		TYPE_STRING,
		PROPERTY_HINT_NONE
		)


func _exit_tree() -> void:
	pass # do nothing


func _require_custom_project_setting(
	setting_name: String,
	default_value: Variant,
	type: int,
	hint: int = PROPERTY_HINT_NONE,
	hint_string: String = ""
	) -> void:

	if ProjectSettings.has_setting(setting_name):
		return

	var setting_info: Dictionary = {
		"name": setting_name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(setting_name, default_value)
	ProjectSettings.save()

