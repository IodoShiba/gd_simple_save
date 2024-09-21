

const ValueCollector := preload("res://addons/gd_simple_save/value_collector.gd")
const ValueDistributer := preload("res://addons/gd_simple_save/value_distributer.gd")
const BytesBox := preload("res://addons/gd_simple_save/internals/BytesBox.gd")

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
static func read_save_file(file : FileAccess, footer_size : int, footer_reader : Callable) -> Dictionary:
	var collections_count : int = file.get_64()

	var read := {}

	for __ in collections_count:
		var subject_key_length := file.get_64()
		var maybe_utf8_key := file.get_buffer(subject_key_length)
		if maybe_utf8_key.is_empty():
			assert(false, "failed to parse collection key.")
			return {}
		var subject_key : StringName = StringName(maybe_utf8_key.get_string_from_utf8())
		
		var subject_size : int = file.get_64()
		var bytes_span := file.get_buffer(subject_size)
		var bytes_footer := file.get_buffer(footer_size)
		match footer_reader.call(bytes_span, bytes_footer):
			false:
				push_error("footer checking failed.")
				return {}
			true:
				pass # accepted. do nothing.
			var not_bool:
				assert(false, "Invalid return type. returned: %s" % not_bool)

		var saved_collection : Dictionary = read_dictionary(bytes_span)
		var distributer := ValueDistributer.new()
		distributer.values = saved_collection

		read[subject_key] = distributer

	return read


static func read_dictionary(bytes : PackedByteArray) -> Dictionary:
	var decoded : Variant = bytes_to_var(bytes)
	assert(typeof(decoded) == TYPE_DICTIONARY)

	return decoded


# encode functions

static func write_box(box : BytesBox, values : Dictionary, footer_maker : Callable) -> void:
	box.store_i64(values.size())

	for k : StringName in values:
		var collector_each : ValueCollector = values[k]

		var key_utf8 := String(k).to_utf8_buffer()
		box.store_i64(key_utf8.size())
		box.store_bytes(key_utf8)

		var collector_byte_expression := var_to_bytes(collector_each.values)
		var maybe_footer : Variant = footer_maker.call(collector_byte_expression)
		assert(typeof(maybe_footer) == TYPE_PACKED_BYTE_ARRAY)
		var footer : PackedByteArray = maybe_footer
		
		box.store_i64(collector_byte_expression.size())
		box.store_bytes(collector_byte_expression)
		if not footer.is_empty():
			box.store_bytes(footer)
