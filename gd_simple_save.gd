extends Node

const Consts := preload("res://addons/gd_simple_save/internals/consts.gd")
const ValueCollector := preload("res://addons/gd_simple_save/value_collector.gd")
const ValueDistributer := preload("res://addons/gd_simple_save/value_distributer.gd")
const Encoder := preload("res://addons/gd_simple_save/internals/encoder.gd")
const BytesBox := preload("res://addons/gd_simple_save/internals/BytesBox.gd")

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

## Fires all on_store_requested callbacks and save accumulated data to file. [br]
## [param save_key]: Data will be saved in the file of this name with extension appended.
## You will also use this key when you want to restore states saved with this method. [br]
## [param encrypt_key]: key to use encrypt file. keep it empty if you want to save without encryption. [br]
## [param footer_maker]: Callable<(data : PackedByteArray) -> footer : PackedByteArray> 
## which returns checksum or so according to byte array representation of saved data.
## returned value will be appended to the original byte representation. [br]
func request_store(save_key : StringName, encrypt_key : String = "", footer_maker : Callable = func(__): return PackedByteArray()) -> void:
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

	var file : FileAccess 
	if encrypt_key.is_empty():
		file = FileAccess.open(to_save_path(save_key), FileAccess.WRITE)
	else :
		file = FileAccess.open_encrypted_with_pass(to_save_path(save_key), FileAccess.WRITE, encrypt_key)
	if FileAccess.get_open_error():
		assert(false, "open error occures. code: %s" % error_string(FileAccess.get_open_error()))
		return

	var bytes_box := BytesBox.new()
	
	if not encrypt_key.is_empty():
		bytes_box.store_i64(-0x7ACE_BABE_A7E7_AED5)

	Encoder.write_box(bytes_box, collectors, footer_maker)

	bytes_box.write_to(file)
	file.close()

## Load saved file and fires all on_restore_requested callbacks to restore saved data. [br]
## [param save_key]: Save file name without extension which you want to read and restore from. 
## [param decrypter]: Key to decrypt content of save file. Leave this empty if the save file was not encrypted. [br]
## [param footer_size]: byte size of footer.
## [param footer_checker]: Callable<(data : PackedByteArray, footer : PackedByteArray) -> bool> 
## which read footer, challenge checksum and returns whether the data acceptable or not.
## returned value will be appended to the original byte representation. [br]
func request_restore(save_key : StringName, decrypt_key : String = "", footer_size : int = 0, footer_checker : Callable = func(_0, _1): return true) -> bool:
	if not is_save_file_exists(save_key):
		push_warning("save file with key %s does not exists." % save_key)

	var file : FileAccess 
	if decrypt_key.is_empty():
		file = FileAccess.open(to_save_path(save_key), FileAccess.READ)
	else:
		file = FileAccess.open_encrypted_with_pass(to_save_path(save_key), FileAccess.READ, decrypt_key)
	if FileAccess.get_open_error():
		push_error("open error occures. code: %s" % error_string(FileAccess.get_open_error()))
		return false

	# パスワード正当性の確認
	if not decrypt_key.is_empty():
		var challenge := file.get_64()
		if challenge != -0x7ACE_BABE_A7E7_AED5:
			assert(false, "Incollect password.")
			return false

	var distributers : Dictionary = Encoder.read_save_file(file, footer_size, footer_checker)

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
