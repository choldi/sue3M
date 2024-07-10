extends Node

var width:int
var height:int
var x_start:int
var y_start:int
var offset:int
var y_offset:int
var start_minutes:int
var start_seconds:int


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
	pass # Replace with function body.

func get_boardsize():
	return Vector2(width,height)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
