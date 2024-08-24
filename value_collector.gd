
# class_name ValueCollector 
extends RefCounted

var values : Dictionary = {}
var value_set : bool = false

func set_value(key : StringName, value : Variant) -> void:
	values[key] = value


