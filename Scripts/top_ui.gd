extends TextureRect

signal stop_game

@onready var score_label=$MarginContainer/HBoxContainer/ScoreLabel
@onready var time_label=$MarginContainer/HBoxContainer/TimeLabel
@onready var hi_points=$MarginContainer/HBoxContainer/HiScore/hi_points
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_grid_update_score(amount_to_change):
	var score=score_label.text.to_int()
	score+=amount_to_change
	if score > 9999999:
		score = score - 9999999
	score_label.text = "%07d" % score
	
	
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
	


func _on_grid_reset_score():
	var score=0
	score_label.text = "%07d" % score


func _on_grid_reset_timer():
	var start_minutes=GlobalVars.start_minutes
	var start_seconds=GlobalVars.start_seconds
	time_label.text="%d:%02d" % [start_minutes,start_seconds]
	pass # Replace with function body.


func _on_grid_display_hi_score(hi_score):
	hi_points.text = "%07d" % hi_score


func _on_grid_check_hi_score():
	var hi_num=int(hi_points.text)
	var score=int(score_label.text)
	if score>hi_num:
		GlobalVars.save_hiscore(score_label.text)
		hi_points.text=score_label.text
