extends TextureRect
@onready var lbl_hi=$MarginContainer/lblhi
@onready var lbl_score=$MarginContainer/lblscore

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_grid_display_hi_score(hi_score):
	lbl_hi.text = "%07d" % hi_score
	
func _on_grid_update_score(amount_to_change):
	var score=lbl_score.text.to_int()
	score+=amount_to_change
	if score > 9999999:
		score = score - 9999999
	lbl_score.text = "%07d" % score
	


func _on_grid_reset_score():
	var score=0
	lbl_score.text = "%07d" % score




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_ui_update_hi_bottom():
	var hi_num=int(lbl_hi.text)
	var score=int(lbl_score.text)
	if score>hi_num:
		GlobalVars.max_score=lbl_score.text
		GlobalVars.save_config()
		lbl_hi.text=lbl_score.text
