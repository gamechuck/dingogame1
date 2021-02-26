# Loader for all the game's data.
extends Node

func load_dataJSON() -> int:
	## Load all report_templates, clues, etc... from their relevant data JSON.
	var data_dict := {
		"layers": {
			"path": Flow.PATH_DATA_LAYERS,
			"setter": funcref(self, "_set_layers_data")
		}
	}

	var file : File = File.new()
	var error : int = OK

	for key in data_dict.keys():
		var path : String = data_dict[key].path
		if file.file_exists(path):
			if ConfigData.verbose_mode: print("Attempting to load reporting data from '{0}'.".format([path]))
			var data : Dictionary = Flow.load_JSON(path)
			if data.empty():
				push_error("Failed to open the data settings at '{0}' for loading purposes.".format([path]))
			else:
				(data_dict[key].setter as FuncRef).call_func(data)

		else:
			push_error("Essential file '{0}' does not exist, check its existence!".format([path]))
			error = ERR_FILE_CORRUPT

	return error

func _set_layers_data(data : Dictionary) -> void:
	Flow.layer_data = data
