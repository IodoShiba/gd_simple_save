extends RefCounted

var bytes : PackedByteArray

func get_bytes() -> PackedByteArray:
    return bytes


func write_to(file : FileAccess) -> void:
    file.store_buffer(bytes)


func store_bytes(extra_bytes : PackedByteArray) -> void:
    bytes.append_array(extra_bytes)


func store_i64(value : int) -> void:
    bytes.resize(bytes.size() + 8)
    bytes.encode_s64(bytes.size() - 8, value)
