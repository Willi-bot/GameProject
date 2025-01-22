extends Node


@export var resolutions = {
	"3840x2160": Vector2(3840,2160),
	"2560x1440": Vector2(2560,1440),
	"1920x1080": Vector2(1920,1080),
	"1366x768": Vector2(1366,768),
	"1280x720": Vector2(1280,720),
	"1440x900": Vector2(1440,900),
	"1600x900": Vector2(1600,900),
	"1024x600": Vector2(1024,600),
	"800x600": Vector2(800,600),
	"640x360": Vector2(640,360)
}

@export var save_dict = {}


func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		var save_file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var json_object = JSON.new()
		var parse_err = json_object.parse(save_file.get_as_text())
		save_dict = json_object.get_data()
		
		var master_index = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(master_index, linear_to_db(save_dict["master_vol"]))
		var music_index = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(music_index, linear_to_db(save_dict["music_vol"]))
		var sfx_index = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_db(sfx_index, linear_to_db(save_dict["effect_vol"]))
		
		AudioServer.set_bus_mute(0, save_dict["muted"])
		
		var res = resolutions.values()[save_dict["res"]]
		
		get_window().set_size(res)
		get_window().move_to_center()
