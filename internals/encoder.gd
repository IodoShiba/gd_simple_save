

const ValueCollector := preload("res://addons/gd_simple_save/value_collector.gd")
const ValueDistributer := preload("res://addons/gd_simple_save/value_distributer.gd")

### セーブファイルの構造
## 見方
# size / struct : info

## 全体
# 64 : コレクションの個数
# collection[*] : 各コレクション
# 0 : 終

## collection
# pascal_string : キー
# dictionary : 値
# 0 : 終

## dictionary
# 64 : ペア数
# dic_pair[*] : 辞書ペア
# 0 : 終

## dic_pair
# value : キー値
# value : 値
# 0 : 終

## value
# 64 : 型番号
# int / double / bool / string / array / dictionary / null : 中身
# 0 : 終

## array
# 64 : 配列長
# value[*] : 中身
# 0 : 終


# decode functions

## return type : Dictionary<StringName -> ValueDistributer>
static func read_save_file(file : FileAccess) -> Dictionary:
	var collections_count : int = file.get_64()

	var read := {}

	for __ in collections_count:
		var subject_key : StringName = StringName(file.get_pascal_string())
		var saved_collection : Dictionary = read_dictionary(file)
		var distributer := ValueDistributer.new()
		distributer.values = saved_collection

		read[subject_key] = distributer

	return read


static func read_dictionary(file : FileAccess) -> Dictionary:
	var pairs_count : int = file.get_64()

	var dic := {}

	for __ in pairs_count:
		var key = read_value(file)
		var value = read_value(file)

		dic[key] = value

	return dic


static func read_value(file : FileAccess) -> Variant:
	var value_type : int = file.get_64()

	match value_type:
		TYPE_INT:
			return file.get_64()
		TYPE_FLOAT:
			return file.get_double()
		TYPE_BOOL:
			var bits := file.get_8()
			if bits == 0:
				return false
			elif bits == 1:
				return true
			else:
				__unexpected("invalid boolean value of %d." % bits)
				return false
		TYPE_STRING:
			return file.get_pascal_string()
		TYPE_STRING_NAME:
			return StringName(file.get_pascal_string())
		TYPE_DICTIONARY:
			return read_dictionary(file)
		TYPE_ARRAY:
			return read_array(file)
		TYPE_NIL:
			return null
		_:
			return __unexpected("unexpected value type %d." % value_type)


static func read_array(file : FileAccess) -> Array:
	var count := file.get_64()

	var array := []

	for __ in count:
		array.append(read_value(file))

	return array


# encode functions

static func write_save_file(file : FileAccess, values : Dictionary) -> void:
	file.store_64(values.size())

	for k : StringName in values:
		write_collection(file, k, values[k].values)


static func write_collection(file : FileAccess, subject_key : StringName, value : Dictionary) -> void:
	file.store_pascal_string(subject_key)
	write_dictionary(file, value)


static func write_dictionary(file : FileAccess, dic : Dictionary) -> void:
	file.store_64(dic.size())

	for k in dic:
		write_value(file, k)
		write_value(file, dic[k])


static func write_value(file : FileAccess, value : Variant) -> void:
	file.store_64(typeof(value))

	match typeof(value):
		TYPE_INT:
			file.store_64(value)
		TYPE_FLOAT:
			file.store_double(value)
		TYPE_BOOL:
			file.store_8(1 if value else 0)
		TYPE_STRING:
			file.store_pascal_string(value)
		TYPE_STRING_NAME:
			file.store_pascal_string(String(value))
		TYPE_DICTIONARY:
			write_dictionary(file, value)
		TYPE_ARRAY:
			write_array(file, value)
		TYPE_NIL:
			pass # nil type value takes zero bites. therefore, do nothing.


static func write_array(file : FileAccess, array : Array) -> void:
	file.store_64(array.size())

	for each in array:
		write_value(file, each)


static func __unexpected(message : String) -> Object:
	assert(false, message)
	return null
