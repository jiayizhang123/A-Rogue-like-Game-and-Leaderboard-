class_name FormData

extends Object

var boundary: String = "--WebKitFormBoundary7MA4YWxkTrZu0gW"

var files: Dictionary = {}
var fields: Dictionary = {}

func add_field(name: String, value: String) -> void:
	fields[name] = value

func add_file(name: String, filename: String, data: PackedByteArray) -> void:
	files[name] = {"filename": filename, "data": data}

func get_data() -> PackedByteArray:
	var data: String = ""

	for field_name in fields.keys():
		data += "--" + boundary + "\r\n"
		data += "Content-Disposition: form-data; name=\"" + field_name + "\"\r\n\r\n"
		data += fields[field_name] + "\r\n"

	for file_name in files.keys():
		data += "--" + boundary + "\r\n"
		data += "Content-Disposition: form-data; name=\"" + file_name + "\"; filename=\"" + files[file_name]["filename"] + "\"\r\n"
		data += "Content-Type: application/octet-stream\r\n\r\n"
		data += files[file_name]["data"] + "\r\n"

	data += "--" + boundary + "--\r\n"

	return data.to_utf8_buffer()

func get_boundary() -> String:
	return boundary
