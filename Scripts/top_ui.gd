extends TextureRect

signal stop_game

@onready var score_label=$MarginContainer/HBoxContainer/ScoreLabel
@onready var time_label=$MarginContainer/HBoxContainer/TimeLabel
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grid_update_score(amount_to_change):
	var score=score_label.text.to_int()
	score+=amount_to_change
	if score > 999999:
		score = score - 999999
	score_label.text = "%06d" % score
	
	
	pass # Replace with function body.


func _on_grid_update_timer(delta):
	var time_array=time_label.text.split(":")
	var minutes=time_array[0].to_int()
	var seconds=time_array[1].to_int()
	seconds+=minutes*60
	seconds+=delta
	var total_seconds=seconds
	minutes=int(seconds/60)
	seconds-=minutes*60
	time_label.text="%d:%02d" % [minutes,seconds]
	seconds +=minutes*60
	if seconds<=0:
		emit_signal("stop_game")
	
