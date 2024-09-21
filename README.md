# Gd Simple Save

A small set of GDScript which support storing and restoring states of your game.

## Installation

1. Simply duplicate folder 'addons/gd_simple_save' to your game project's 'addons' folder.
2. Add 'gd_simple_save.gd' to the project's Singleton.
3. Use 'gd_simple_save.gd'.

## How to use

1. Call 'gd_simple_save.gd::add_subject()' to make your values of node storable.
2. Call 'gd_simple_save.gd::remove_subject()' when your node is no longer need to be saved.
3. Call 'gd_simple_save.gd::request_store()' to save your game state.
4. Call 'gd_simple_save.gd::request_restore()' to load and restore your game state.
5. This kit supports simple feature which allows you to appending metadata to your savedata, checksumming and encrypting via Godot's standard functionalities.

## Notes

- Testing this asset conducted via (GUT)[https://github.com].

## Examples

```gdscript
# const SimpleSave = preload('res://addons/gd_simple_save/gd_simple_save.gd')

func saving() -> void:
	var test_subj_0 := TestSaveSubject.new()
	test_subj_0.clear()

	SimpleSave.add_subject(&"test_subj_0", test_subj_0.on_store_requested, test_subj_0.on_restore_requested)

	test_subj_0.use_int_0 = true
	test_subj_0.use_int_1 = true
	test_subj_0.use_int_2 = true
	test_subj_0.use_float_0 = true
	test_subj_0.use_float_1 = true
	test_subj_0.use_bool_0 = true
	test_subj_0.use_string_0 = true
	test_subj_0.use_string_name_0 = true
	test_subj_0.use_array_0 = true
	test_subj_0.use_dic_0 = true

	test_subj_0.int_0 = 10
	test_subj_0.int_1 = 0x7FFF_FFFF_FFFF_FFFF
	test_subj_0.int_2 = -0x7FFF_FFFF_FFFF_FFFF
	test_subj_0.float_0 = 12.34
	test_subj_0.float_1 = INF
	test_subj_0.bool_0 = true
	test_subj_0.string_0 = "unquote"
	test_subj_0.string_name_0 = &"mnquote"
	test_subj_0.array_0 = [0, 1, "a", 0.9, false]
	test_subj_0.dic_0 = {"a": 0, "b": "siqo", "c": 3.14}

	SimpleSave.request_store(&"test_save_0")

	test_subj_0.clear()

	var restore_returned := SimpleSave.request_restore(&"test_save_0")

	assert_eq(restore_returned, true)
	assert_eq(test_subj_0.int_0, 10)
	assert_eq(test_subj_0.int_1, 0x7FFF_FFFF_FFFF_FFFF)
	assert_eq(test_subj_0.int_2, -0x7FFF_FFFF_FFFF_FFFF)
	assert_eq(test_subj_0.float_0, 12.34)
	assert_eq(test_subj_0.float_1, INF)
	assert_eq(test_subj_0.bool_0, true)
	assert_eq(test_subj_0.string_0, "unquote")
	assert_eq(test_subj_0.string_name_0, &"mnquote")
	assert_eq(test_subj_0.array_0, [0, 1, "a", 0.9, false])
	assert_eq(test_subj_0.dic_0, {"a": 0, "b": "siqo", "c": 3.14})

	SimpleSave.remove_subject(&"test_subj_0")


class TestSaveSubject extends RefCounted:
	var use_int_0 : bool
	var use_int_1 : bool
	var use_int_2 : bool
	var use_float_0 : bool
	var use_float_1 : bool
	var use_bool_0 : bool
	var use_string_0 : bool
	var use_string_name_0 : bool
	var use_array_0 : bool
	var use_dic_0 : bool

	var int_0 : int
	var int_1 : int
	var int_2 : int
	var float_0 : float
	var float_1 : float
	var bool_0 : bool
	var string_0 : String
	var string_name_0 : StringName
	var array_0 : Array
	var dic_0 : Dictionary

	func on_store_requested(collector : SimpleSave.ValueCollector) -> void:
		if use_int_0:
			collector.set_value(&"int_0", int_0)
		if use_int_1:
			collector.set_value(&"int_1", int_1)
		if use_int_2:
			collector.set_value(&"int_2", int_2)
		if use_float_0:
			collector.set_value(&"float_0", float_0)
		if use_float_1:
			collector.set_value(&"float_1", float_1)
		if use_bool_0:
			collector.set_value(&"bool_0", bool_0)
		if use_string_0:
			collector.set_value(&"string_0", string_0)
		if use_string_name_0:
			collector.set_value(&"string_name_0", string_name_0)
		if use_array_0:
			collector.set_value(&"array_0", array_0)
		if use_dic_0:
			collector.set_value(&"dic_0", dic_0)

		
	func on_restore_requested(distributor : SimpleSave.ValueDistributer) -> void:
		if use_int_0:
			int_0 = distributor.get_value(&"int_0")
		if use_int_1:
			int_1 = distributor.get_value(&"int_1")
		if use_int_2:
			int_2 = distributor.get_value(&"int_2")
		if use_float_0:
			float_0 = distributor.get_value(&"float_0")
		if use_float_1:
			float_1 = distributor.get_value(&"float_1")
		if use_bool_0:
			bool_0 = distributor.get_value(&"bool_0")
		if use_string_0:
			string_0 = distributor.get_value(&"string_0")
		if use_string_name_0:
			string_name_0 = distributor.get_value(&"string_name_0")
		if use_array_0:
			array_0 = distributor.get_value(&"array_0")
		if use_dic_0:
			dic_0 = distributor.get_value(&"dic_0")

		
	func clear() -> void:
		int_0 = 0
		int_1 = 0
		int_2 = 0
		float_0 = 0.0
		float_1 = 0.0
		bool_0 = false
		string_0 = ""
		string_name_0 = &""
		array_0.clear()
		dic_0.clear()

```
