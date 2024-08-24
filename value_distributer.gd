#class_name ValueDistributer
extends RefCounted

var values : Dictionary = {}


func has(key : String) -> bool:
	return values.has(key)


func get_value(key : String) -> Variant:
	return values[key]
