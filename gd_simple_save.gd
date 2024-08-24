extends Node

const Consts := preload("res://addons/gd_simple_save/internals/consts.gd")
const ValueCollector := preload("res://addons/gd_simple_save/value_collector.gd")
const ValueDistributer := preload("res://addons/gd_simple_save/value_distributer.gd")
const Encoder := preload("res://addons/gd_simple_save/internals/encoder.gd")


# Dictionary[StringName -> Array[Callable]]
var subjects : Dictionary = {}

func add_subject(subject_key : StringName, on_store_requested : Callable, on_restore_requested : Callable) -> void:
	if subjects.has(subject_key):
		assert(false, "Given subject_key (%s) already exists." % subject_key)
		return

	var callbacks : Array[Callable] = [on_store_requested, on_restore_requested]
	subjects[subject_key] = callbacks


func remove_subject(subject_key : StringName) -> void:
	subjects.erase(subject_key)


func request_store(save_key : StringName) -> void:
	var collectors : Dictionary = {}

	for k in subjects:
		var new_collector := ValueCollector.new()
		
		subjects[k][0].call(new_collector)

		if new_collector.values.is_empty():
			assert(false, "Data collection method did not set any data. key: %s." % k)
			return

		collectors[k] = new_collector

	if not DirAccess.dir_exists_absolute(get_save_directory_path()):
		DirAccess.make_dir_recursive_absolute(get_save_directory_path())

	var file := FileAccess.open(to_save_path(save_key), FileAccess.WRITE)
	if FileAccess.get_open_error():
		assert("open error occures. code: %s" % error_string(FileAccess.get_open_error()))
		return

	Encoder.write_save_file(file, collectors)
	file.close()


func request_restore(save_key : StringName) -> bool:
	if not is_save_file_exists(save_key):
		push_warning("save file with key %s does not exists." % save_key)

	var file := FileAccess.open(to_save_path(save_key), FileAccess.READ)
	if FileAccess.get_open_error():
		push_error("open error occures. code: %s" % error_string(FileAccess.get_open_error()))
		return false

	var distributers : Dictionary = Encoder.read_save_file(file)

	for k in subjects:
		subjects[k][1].call(distributers[k])

	file.close()
	return true


func get_subject_keys() -> Array[StringName]:
	var keys_variant_array := subjects.keys()
	var keys : Array[StringName] = []
	keys.assign(keys_variant_array)
	return keys


func is_save_file_exists(save_key : StringName) -> bool:
	var save_path := to_save_path(save_key)

	return FileAccess.file_exists(save_path)


func to_save_path(save_key : StringName) -> String:
	var save_dir_path : String = get_save_directory_path()

	var save_ext : String = get_save_extension()

	if not save_ext.begins_with("."):
		save_ext = "." + save_ext

	var save_path : String = save_dir_path.path_join(save_key.repeat(1) + save_ext)
	return save_path


func get_save_directory_path() -> String:
	# var setting_name := "application/savedata/save_path" #Consts.SETTING_NAME_SAVE + Consts.SETTING_VALUE_SAVE_PATH
	# if not ProjectSettings.has_setting(setting_name):
	# 	assert(false, "setting does not exists.")
	# 	return ""

	# var save_dir_path : String = ProjectSettings.get_setting(setting_name)
	
	# if save_dir_path.is_empty():
	# 	assert(false, "Save file target directory not set.")
	# 	return ""

	# return save_dir_path
	return Consts.SAVE_PATH # has_setting, get_settingが失敗するため、ワークアラウンド


func get_save_extension() -> String:
	# var setting_name := Consts.SETTING_NAME_SAVE + Consts.SETTING_VALUE_SAVE_EXTENSION
	# if not ProjectSettings.has_setting(setting_name):
	# 	assert(false, "setting does not exists.")
	# 	return ""

	# var save_ext : String = ProjectSettings.get_setting(setting_name)
	# if save_ext.is_empty():
	# 	assert(false, "Save file extension not set.")
	# 	return ""

	# return save_ext
	return Consts.SAVE_EXTENSION # has_setting, get_settingが失敗するため、ワークアラウンド
