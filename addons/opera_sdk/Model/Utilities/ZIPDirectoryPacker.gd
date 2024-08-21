extends Node
class_name ZIPDirectoryPacker

var _has_errors_on_packing_files: bool
var _root_folder_path: String
var _zipPacker: ZIPPacker

func archive(
	source_folder_path: String,
	output_path: String
) -> bool:
	_has_errors_on_packing_files = false
	_root_folder_path = source_folder_path
	_zipPacker = ZIPPacker.new()
	
	var open_error = _zipPacker.open(output_path)
	if open_error != OK:
		print("Error on packing the bundle. Could not open a ZIP Packer for the path " + output_path + ". Error: " + str(open_error))
		return false
	
	_pack_directory("")
	
	var close_error = _zipPacker.close()
	if close_error != OK:
		print("Error on packing the bundle. Could not close a ZIP Packer for the path " + output_path + ". Error: " + str(close_error))
		return false
	
	if _has_errors_on_packing_files:
		print("Errors on packing the bundle files. See the messages in the console for the details")
	
	return !_has_errors_on_packing_files

func _pack_directory(local_folder_path: String) -> void:
	# This is a recursive function. If we have already got errors in other execution paths
	# there is no point in continuing. So let's just interrupt all the other recursive calls.
	if _has_errors_on_packing_files:
		return
	
	var folder_path = _root_folder_path + "/" + local_folder_path
	var dir = DirAccess.open(folder_path)
	
	if dir:
		var files = dir.get_files()
		
		for file in files:
			var path_to_file_local = file if !local_folder_path else local_folder_path + "/" + file
			var path_to_file = _root_folder_path + "/" + path_to_file_local
			
			var file_bytes = FileAccess.get_file_as_bytes(path_to_file)
			if file_bytes.size() == 0:
				print("Could not open the file: " + path_to_file + ". Error: " + str(FileAccess.get_open_error()))
				_has_errors_on_packing_files = true
				return
			
			var start_file_error = _zipPacker.start_file(path_to_file_local)
			if start_file_error != OK:
				print("Could not start packing the file: " + path_to_file + ". Error: " + str(start_file_error))
				_has_errors_on_packing_files = true
				return
			
			var write_file_error = _zipPacker.write_file(FileAccess.get_file_as_bytes(path_to_file))
			if write_file_error != OK:
				print("Could not write the file into the archive: " + path_to_file + ". Error: " + str(write_file_error))
				_has_errors_on_packing_files = true
				_zipPacker.close_file()
				return
			
			var close_file_error = _zipPacker.close_file()
			if close_file_error != OK:
				print("Could not close the archive file: " + path_to_file + ". Error: " + str(close_file_error))
				_has_errors_on_packing_files = true
				return
		
		var subdirectories = dir.get_directories()
		
		for subdirectory in subdirectories:
			_pack_directory(subdirectory if !local_folder_path else local_folder_path + "/" + subdirectory)
	else:
		print("Could not open the folder: " + folder_path + ". Error: " + str(DirAccess.get_open_error()))
		_has_errors_on_packing_files = true
