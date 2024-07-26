extends Node

var width:int
var height:int
var x_start:int
var y_start:int
var offset:int
var y_offset:int
var start_minutes:int
var start_seconds:int
var score_file:String
var vol_mixer:float
var vol_music:float
var vol_sfx:float



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

	load_hiscore()
	set_vol("Master",1)
	set_vol("Music",1)
	set_vol("SFX",1)	
	pass # Replace with function body.



func get_boardsize():
	return Vector2(width,height)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func save_hiscore(score):
	var file = FileAccess.open(score_file,FileAccess.WRITE)
	file.store_string(score)
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


