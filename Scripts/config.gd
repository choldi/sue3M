extends Node

var width:int
var height:int
var x_start:int
var y_start:int
var offset:int
var y_offset:int
var start_minutes:int
var start_seconds:int
var config_file:String
var score_file:String
var vol_mixer:float
var vol_music:float
var vol_sfx:float
var max_score:int
var last_scene
var grid_scene
var main_scene
var num_bonus_seconds:int
var min_piece_for_bonus:int
var piece_type:int
# Called when the node enters the scene tree for the first time.
func _ready():
	width=8
	height=10
	x_start=64
	y_start=800
	offset=64
	y_offset=2
	start_minutes=3
	start_seconds=0
	score_file="user://scoresave.cfg"
	config_file="user://sue3m.cfg"
	num_bonus_seconds=10
	min_piece_for_bonus=6
	piece_type=0
	
	
	
	var config = ConfigFile.new()
	var err = config.load(config_file) 
	if err != OK: 
		config.set_value("VOLUME","Master",0.5)
		config.set_value("VOLUME","Music",0.5)
		config.set_value("VOLUME","SFX",0.5)
		config.set_value("SCORE","HI_SCORE",0)
		config.save(config_file)
	else:
		vol_mixer=float(config.get_value("VOLUME","Master"))
		vol_music=float(config.get_value("VOLUME","Music"))
		vol_sfx=float(config.get_value("VOLUME","SFX"))
		max_score=int(config.get_value("SCORE","HI_SCORE"))
	set_vol("Master",vol_mixer)
	set_vol("Music",vol_music)
	set_vol("SFX",vol_sfx)
	load_hiscore()
	pass # Replace with function body.

func save_config():
	var config = ConfigFile.new()
	config.set_value("VOLUME","Master",vol_mixer)
	config.set_value("VOLUME","Music",vol_music)
	config.set_value("VOLUME","SFX",vol_sfx)
	config.set_value("SCORE","HI_SCORE",max_score)
	config.save(config_file)



func get_boardsize():
	return Vector2(width,height)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func save_hiscore(score):
	var file = FileAccess.open(score_file,FileAccess.WRITE)
	file.store_string(score)
	max_score=score
	file = null
	
func load_hiscore():
	var content=0
	if FileAccess.file_exists(score_file):
		var file = FileAccess.open(score_file,FileAccess.READ)
		content = file.get_as_text()
	else:
		save_hiscore("000000")
	return content



func set_vol(audio_src,vol):
	var bus_index=AudioServer.get_bus_index(audio_src)
	AudioServer.set_bus_volume_db(bus_index,linear_to_db(vol))
	if audio_src=="Master":
		self.vol_mixer=vol
	elif audio_src=="Music":
		self.vol_music=vol
	elif audio_src=="SFX":
		self.vol_sfx=vol

func get_vol(audio_src):
	if audio_src=="Master":
		return self.vol_mixer
	elif audio_src=="Music":
		return self.vol_music
	elif audio_src=="SFX":
		return self.vol_sfx


