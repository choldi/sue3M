extends Node2D

#Varibles para grid
@export var width:int
@export var height:int
@export var x_start:int
@export var y_start:int
@export var offset:int

#pieces in board
var all_pieces=[]

#matches in board
var all_matches=[]

#touch Variables
var first_touch=Vector2(0,0)
var final_touch=Vector2(0,0)


#possible pieces to paint in board
var possible_pieces=[
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn"),
]
# Called when the node enters the scene tree for the first time.
func _ready():
	all_pieces=make_2d_array()	
	all_matches=make_2d_array()	
	spawn_pieces()
	print(all_pieces)
	pass # Replace with function body.

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func grid_to_pixel(column,row):
	var new_x= x_start + offset*column
	var new_y= y_start + -offset*row
	return Vector2(new_x,new_y)

func pixel_to_grid(pixel_x,pixel_y):	
	var column = round((pixel_x - x_start)/offset)
	var row = round((pixel_y - y_start)/-offset)
	return Vector2(column,row)

func spawn_pieces():
	randomize()
	for i in width:
		for j in height:
			var rand = floor(randf_range(0,possible_pieces.size()))
			var piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.position=grid_to_pixel(i,j)
			all_pieces[i][j]=piece
			
func check_match_left(column,row,color,items,items_tot):
	if column>0:
		print("left")
		if (all_pieces[column-1][row].color==color):
			print("match")
			if all_matches[column-1][row]==null:
				items+=1
				all_matches[column-1][row]=true
				var up_check=check_match_up(column-1,row,color,0,0)
				var down_check=check_match_down(column-1,row,color,0,0)
				items_tot+=up_check[1]+down_check[1]+1
				return check_match_left(column-1,row,color,items,items_tot)				
			else:
				return [items,items_tot]
		else:
			return [items,items_tot]
	else:
		return [items,items_tot]
		
func check_match_right(column,row,color,items,items_tot):
	if column<width-1:
		print("right")
		if (all_pieces[column+1][row].color==color):
			print("match")
			if all_matches[column+1][row]==null:
				items+=1
				all_matches[column+1][row]=true
				var up_check=check_match_up(column+1,row,color,0,0)
				var down_check=check_match_down(column+1,row,color,0,0)
				items_tot+=up_check[1]+down_check[1]+1
				return check_match_right(column+1,row,color,items,items_tot)
			else:
				return [items,items_tot]
		else:
			return [items,items_tot]
	else:
		return [items,items_tot]

func check_match_down(column,row,color,items,items_tot):
	if row>0:
		print("down")
		if (all_pieces[column][row-1].color==color):
			print("match")
			if all_matches[column][row-1]==null:
				items+=1
				all_matches[column][row-1]=true
				var left_check=check_match_left(column,row-1,color,0,0)
				var right_check=check_match_right(column,row-1,color,0,0)
				items_tot+=left_check[1]+right_check[1]+1
				return check_match_down(column,row-1,color,items,items_tot)
			else:
				return [items,items_tot]
		else:
			return [items,items_tot]
	else:
		return [items,items_tot]
		
func check_match_up(column,row,color,items,items_tot):
	if row<height-1:
		print("up")
		if (all_pieces[column][row+1].color==color):
			print("match")
			if all_matches[column][row+1]==null:
				items+=1
				all_matches[column][row+1]=true
				var left_check=check_match_left(column,row+1,color,0,0)
				var right_check=check_match_right(column,row+1,color,0,0)
				items_tot+=left_check[1]+right_check[1]+1
				return check_match_up(column,row+1,color,items,items_tot)
			else:
				return [items,items_tot]
		else:
			return [items,items_tot]
	else:
		return [items,items_tot]

func check_line_row(column,row,color):
	var item=1
	for i in range(column-1,0,-1):
		if all_pieces[i][row].color==color:
			item+=1
		else:
			break
	for i in range(column+1,width-1):
		if all_pieces[i][row].color==color:
			item+=1
		else:
			break
	return item
	
func check_line_column(column,row,color):
	var item=1
	for i in range(row-1,0,-1):
		if all_pieces[column][i].color==color:
			item+=1
		else:
			break
	for i in range(row+1,height-1):
		if all_pieces[column][i].color==color:
			item+=1
		else:
			break
	return item
	

func find_match(column,row):
	var color=all_pieces[column][row].color
	all_matches=make_2d_array()
	all_matches[column][row]=true
	var left_check=check_match_left(column,row,color,0,0)
	var right_check=check_match_right(column,row,color,0,0)
	var up_check=check_match_up(column,row,color,0,0)
	var down_check=check_match_down(column,row,color,0,0)
	print ("left check:" + str(left_check))
	print ("right check:" + str(right_check))
	print ("up check:" + str(up_check))
	print ("down check:" + str(down_check))
	var items_lin_r=check_line_row(column,row,color)
	print ("line items:" + str(items_lin_r))
	var items_lin_c=check_line_column(column,row,color)
	print ("line items:" + str(items_lin_c))
func matches():
	print("matches?")
	pass

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var pos=pixel_to_grid(first_touch.x,first_touch.y)
		print(pos)
		find_match(pos.x,pos.y)

	if Input.is_action_just_released("ui_touch"):
		first_touch = get_global_mouse_position()
		matches()
	if Input.is_action_just_released("ui_mouse_right"):
		spawn_pieces()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	touch_input()
	pass
