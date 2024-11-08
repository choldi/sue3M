extends Node2D

#state machine
enum {wait,move}
var state
#Varibles para grid
var width
var height
var x_start
var y_start
var offset
var y_offset

var magic_seq=0

#pieces in board
var all_pieces=[]

#matches in board
var all_matches=[]
var collections_to_delete=[]

#possible moves
var vect_moves=[]

#touch Variables
var first_touch=Vector2(0,0)
var final_touch=Vector2(0,0)
var controlling=false

#swap back variables
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)


#possible pieces to paint in board
var all_type_pieces=[[
	#preload("res://scenes/rainbow.tscn"),
	preload("res://scenes/blue_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/light_green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/yellow_piece.tscn")
],[
	preload("res://scenes/circle.tscn"),
	preload("res://scenes/diamond.tscn"),
	preload("res://scenes/hexagon.tscn"),
	preload("res://scenes/square.tscn"),
	preload("res://scenes/star.tscn"),
	preload("res://scenes/triangle.tscn")
]]
var possible_pieces

var piece_types = { "blue":0,"green":1,"light_green":2,"orange":3,"pink":4,"yellow":5,
			   "circle":0,"diamond":1,"hexagon":2,"square":3,"star":5,"triangle":5}


@onready var snd_destroy=preload("res://Assets/audio/effects/collapse-47652.mp3")
@onready var snd_addtime=preload("res://Assets/audio/effects/collect-points-190037.mp3")
@onready var direct_sound=preload("res://scenes/asp_direct.tscn")
@onready var options = preload("res://scenes/options.tscn")
@onready var label = preload("res://scenes/floating_text.tscn")

#score variable
signal update_score
signal update_pieces
signal reset_score
signal display_hi_score
signal display_hi_pieces
signal check_hi_score


@export var piece_value:int
var streak=1
var refill_bonus=1

#timer variable
signal update_timer
signal reset_timer
signal start_timer
signal pause_timer_collapse


var end_game=false
var pause_game=false
var pause_timer=false
var destroy_button=false

signal toggle_pause

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		print("Focused!")
		load_status() 
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("Unfocused!")
		save_status()

func start():
	
	all_pieces=make_2d_array()	
	all_matches=make_2d_array()
	spawn_pieces()
	state=move
	end_game=false
	pause_game=false
	destroy_button=false
	emit_signal("reset_score")
	emit_signal("reset_timer")
	emit_signal("start_timer")
	emit_signal("toggle_pause",pause_game)
	get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/toggle_pause").show()
	#get_parent().get_node("background/MarginContainer/margin_nomoves").hide()
			
	get_parent().get_node("GameOver").hide()
	var hi=GlobalVars.max_score
	emit_signal("display_hi_score",int(hi))
	var hi_pieces=GlobalVars.max_pieces
	emit_signal("display_hi_pieces",int(hi_pieces))
	pause_timer=false
# Called when the node enters the scene tree for the first time.
func continue_game():
	all_pieces=make_2d_array()	
	all_matches=make_2d_array()
	get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/toggle_pause").show()
	pause_timer=false
	state=move
	end_game=false
	pause_game=false
	load_status()
	
func _ready():
	width=GlobalVars.width
	height=GlobalVars.height
	x_start=GlobalVars.x_start
	y_start=GlobalVars.y_start
	offset=GlobalVars.offset
	y_offset=GlobalVars.y_offset
#	self is grid, parent is game
	GlobalVars.main_scene=self.get_parent() 
	possible_pieces=all_type_pieces[GlobalVars.piece_type]
	
	var fname=GlobalVars.status_file
	if FileAccess.file_exists(fname):
		continue_game()
	else:
		start()

#	GlobalVars.main_scene=self
			
func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func store_pieces(array_in):
	var array_out=make_2d_array()
	for i in width:
		for j in height:
			var type_piece=array_in[i][j].color
			array_out[i][j]=type_piece
	return array_out

	


func grid_to_pixel(column,row):
	var new_x= x_start + offset*column
	var new_y= y_start + -offset*row
	return Vector2(new_x,new_y)

func pixel_to_grid(pixel_x,pixel_y):	
	var column = round((pixel_x - x_start)/offset)
	var row = round((pixel_y - y_start)/-offset)
	return Vector2(column,row)

func get_central_coordinate(coords: Array) -> Vector2:
	var sum = Vector2(0, 0)
	# Calcular el centroide
	var cv=[]
	for coord in coords:
		var c=Vector2(coord[0],coord[1])
		sum += c
		cv.append(c)
	var centroid = sum / coords.size()
	
	# Encontrar la coordenada más cercana al centroide
	var closest_coord = cv[0]
	var min_distance = centroid.distance_to(closest_coord)
	
	for coord in cv:
		var distance = centroid.distance_to(coord)
		if distance < min_distance:
			min_distance = distance
			closest_coord = coord
	return closest_coord

func spawn_pieces():
	randomize()
	for i in width:
		for j in height:
			var rand = floor(randf_range(0,possible_pieces.size()))
			var piece = possible_pieces[rand].instantiate()
			while check_line_column(i,j,piece.color)>=3 ||check_line_row(i,j,piece.color)>=3:
					piece.queue_free()
					rand = floor(randf_range(0,possible_pieces.size()))
					piece = possible_pieces[rand].instantiate()
			add_child(piece)
			piece.position=grid_to_pixel(i,j)
			all_pieces[i][j]=piece
	#queue_free()

func check_moves_horz(i,j):
	var moves=0
	if i>=width-1-1:
		return 0
	var c=all_pieces[i][j].color
	if (all_pieces[i][j].color == all_pieces[i+1][j].color):
		if (i<=width-4):
			if (all_pieces[i+3][j].color==c):
				moves+=1
				vect_moves.append([[i+3,j],[i+2,j]])
		if (i<=width-3) && (j>0):
			if (all_pieces[i+2][j-1].color==c):
				moves+=1
				vect_moves.append([[i+2,j-1],[i+2,j]])
		if (i<=width-3) && (j<height-1):
			if (all_pieces[i+2][j+1].color==c):
				moves+=1
				vect_moves.append([[i+2,j+1],[i+2,j]])
		if (i>0) && (j>0):
			if (all_pieces[i-1][j-1].color==c):
				moves+=1
				vect_moves.append([[i-1,j-1],[i-1,j]])
		if (i>0) && (j<height-1):
			if (all_pieces[i-1][j+1].color==c):
				moves+=1
				vect_moves.append([[i-1,j+1],[i-1,j]])
	if (all_pieces[i][j].color == all_pieces[i+2][j].color):
		if (i<=width-4):
			if (all_pieces[i+3][j].color==c):
				moves+=1
				vect_moves.append([[i,j],[i+1,j]])
		if (j>0):
			if (all_pieces[i+1][j-1].color==c):
				moves+=1
				vect_moves.append([[i+1,j-1],[i+1,j]])
		if (j<height):
			if (all_pieces[i+1][j+1].color==c):
				moves+=1
				vect_moves.append([[i+1,j+1],[i+1,j]])
	return moves	

func check_moves_vert(i,j):
	var moves=0
	if j>=height-1-1:
		return 0
	var c=all_pieces[i][j].color
	if (all_pieces[i][j].color == all_pieces[i][j+1].color):
		if (j<=height-4):
			if (all_pieces[i][j+3].color==c):
				moves+=1
				vect_moves.append([[i,j+3],[i,j+2]])
		if (j<=height-3) && (i>0):
			if (all_pieces[i-1][j+2].color==c):
				moves+=1
				vect_moves.append([[i-1,j+2],[i,j+2]])
		if (j<=height-3) && (i<width-1):
			if (all_pieces[i+1][j+2].color==c):
				moves+=1
				vect_moves.append([[i+1,j+2],[i,j+2]])
		if (i>0) && (j>0):
			if (all_pieces[i-1][j-1].color==c):
				moves+=1
				vect_moves.append([[i-1,j-1],[i,j-1]])
		if (i>0) && (j<height-1):
			if (all_pieces[i+1][j-1].color==c):
				moves+=1
				vect_moves.append([[i+1,j-1],[i,j-1]])
	if (all_pieces[i][j].color == all_pieces[i][j+2].color):
		if (j<=height-4):
			if (all_pieces[i][j+3].color==c):
				moves+=1
				vect_moves.append([[i,j],[i,j+1]])
		if (i>0):
			if (all_pieces[i-1][j+1].color==c):
				moves+=1
				vect_moves.append([[i-1,j+1],[i,j+1]])
		if (i<width):
			if (all_pieces[i+1][j+1].color==c):
				moves+=1
				vect_moves.append([[i+1,j+1],[i,j+1]])

	return moves	

func sort_moves(x,y):
	var move_x_f=x[0]
	var move_x_t=x[1]
	var move_y_f=y[0]
	var move_y_t=y[1]
	if move_x_f[1]>move_y_f[1]:
		return false
	if move_x_f[1]<move_y_f[1]:
		return true
	if move_x_f[1]==move_y_f[1]:
		if move_x_f[0]>move_y_f[0]:
			return false
		if move_x_f[0]<move_y_f[0]:
			return true
		if move_x_f[0]==move_y_f[0]:
			if move_x_t[1]>move_y_t[1]:
				return false
			if move_x_t[1]<move_y_t[1]:
				return true
			if move_x_t[1]==move_y_t[1]:
				if move_x_t[0]>move_y_t[0]:
					return false
				if move_x_t[0]<move_y_t[0]:
					return true
				else:
					#can't occur
					return false

			

func arrange_vect_moves(v):
	var v_out=[]
	for i in len(v):
		var move=v[i]
		var move_ini=move[0]
		var move_fin=move[1]
		if (move_ini[1]>move_fin[1]):
			v_out.append([move_fin,move_ini])
		else:
			if move_ini[1]==move_fin[1]:
				if move_ini[0]>move_fin[0]:
					v_out.append([move_fin,move_ini])
				else:
					v_out.append([move_ini,move_fin])
			else:
				v_out.append([move_ini,move_fin])
	return v_out
	
func possible_moves(i,j):
	var moves=0
	moves=check_moves_horz(i,j)
	moves+=check_moves_vert(i,j)
	return moves
	
func eliminate_dups(v):
	var v_out=[]
	if len(v)==0:
		return v_out
	var v_temp=v[0]
	v_out.append(v_temp)
	for i in range(1,len(v)):
		var v_new=v[i]
		if !(v_temp[0][0]==v_new[0][0] &&
			 v_temp[0][1]==v_new[0][1] &&
			 v_temp[1][0]==v_new[1][0] &&
			 v_temp[1][1]==v_new[1][1]):
				print("not dup:" + str(i) + "-" + str(v_temp) + "!=" + str(v_new))
				v_out.append(v_new)
				v_temp=v_new
		else:
				print("dup:" + str(i) + "-" + str(v_temp) + "=" + str(v_new))
	return v_out		
	

func available_movements():
	var total=0
	vect_moves=Array()
	for i in height-1:
		for j in width-1:
			total+=possible_moves(j,i)
	vect_moves=arrange_vect_moves(vect_moves)
	print(vect_moves)
	vect_moves.sort_custom(sort_moves)
	print(vect_moves)
	print("len vect:" + str(len(vect_moves)))
	vect_moves=eliminate_dups(vect_moves)
	print(vect_moves)
	print("len vect:" + str(len(vect_moves)))
	return len(vect_moves)
	
func check_match_left(column,row,color,items,items_tot,array_pieces):
	if column>0:
		print("left")
		if (all_pieces[column-1][row].color==color):
			print("match")
			if all_matches[column-1][row]==null:
				items+=1
				all_matches[column-1][row]=color
				all_pieces[column-1][row].match()
				array_pieces.push_back([column-1,row])
				var up_check=check_match_up(column-1,row,color,0,0,array_pieces)
				var down_check=check_match_down(column-1,row,color,0,0,array_pieces)
				items_tot+=up_check[1]+down_check[1]+1
				return check_match_left(column-1,row,color,items,items_tot,array_pieces)				
			else:
				return [items,items_tot,array_pieces]
		else:
			return [items,items_tot,array_pieces]
	else:
		return [items,items_tot,array_pieces]
		
func check_match_right(column,row,color,items,items_tot,array_pieces):
	if column<width-1:
		print("right")
		if (all_pieces[column+1][row].color==color):
			print("match")
			if all_matches[column+1][row]==null:
				items+=1
				all_matches[column+1][row]=color
				all_pieces[column+1][row].match()
				array_pieces.push_back([column+1,row])
				var up_check=check_match_up(column+1,row,color,0,0,array_pieces)
				var down_check=check_match_down(column+1,row,color,0,0,array_pieces)
				items_tot+=up_check[1]+down_check[1]+1
				return check_match_right(column+1,row,color,items,items_tot,array_pieces)
			else:
				return [items,items_tot,array_pieces]
		else:
			return [items,items_tot,array_pieces]
	else:
		return [items,items_tot,array_pieces]

func check_match_down(column,row,color,items,items_tot,array_pieces):
	if row>0:
		print("down")
		if (all_pieces[column][row-1].color==color):
			print("match")
			if all_matches[column][row-1]==null:
				items+=1
				all_matches[column][row-1]=color
				all_pieces[column][row-1].match()
				array_pieces.push_back([column,row-1])
				var left_check=check_match_left(column,row-1,color,0,0,array_pieces)
				var right_check=check_match_right(column,row-1,color,0,0,array_pieces)
				items_tot+=left_check[1]+right_check[1]+1
				return check_match_down(column,row-1,color,items,items_tot,array_pieces)
			else:
				return [items,items_tot,array_pieces]
		else:
			return [items,items_tot,array_pieces]
	else:
		return [items,items_tot,array_pieces]
		
func check_match_up(column,row,color,items,items_tot,array_pieces):
	if row<height-1:
		print("up")
		if (all_pieces[column][row+1].color==color):
			print("match")
			if all_matches[column][row+1]==null:
				items+=1
				all_matches[column][row+1]=color
				all_pieces[column][row+1].match()
				array_pieces.push_back([column,row+1])
				var left_check=check_match_left(column,row+1,color,0,0,array_pieces)
				var right_check=check_match_right(column,row+1,color,0,0,array_pieces)
				items_tot+=left_check[1]+right_check[1]+1
				return check_match_up(column,row+1,color,items,items_tot,array_pieces)
			else:
				return [items,items_tot,array_pieces]
		else:
			return [items,items_tot,array_pieces]
	else:
		return [items,items_tot,array_pieces]

func check_line_row(column,row,color):
	var item=1
	var i=column-1
	while i>-1:
		if all_pieces[i][row]!=null &&  all_pieces[i][row].color==color:
			item+=1
			i=i-1
		else:
			break
	i=column+1
	while i<width:
		if all_pieces[i][row]!=null &&  all_pieces[i][row].color==color:
			item+=1
			i=i+1
		else:
			break
	return item
	
func check_line_column(column,row,color):
	var item=1
	var i=row-1
	while i>-1:
		if all_pieces[column][i]!=null && all_pieces[column][i].color==color:
			item+=1
			i=i-1
		else:
			break
	i=row+1
	while i<height:
		if all_pieces[column][i]!=null && all_pieces[column][i].color==color:
			item+=1
			i=i+1
		else:
			break
	return item

	

func find_match(column,row):
	var pieces_to_delete=[]
	pieces_to_delete.push_back([column,row])
	var color=all_pieces[column][row].color
	var items_lin_r=check_line_row(column,row,color)
	var items_lin_c=check_line_column(column,row,color)
	if items_lin_r>=3 or items_lin_c>=3:
		print("items_line:" + str(items_lin_r) + " - items_column:" + str(items_lin_c))
		all_matches[column][row]=color
		all_pieces[column][row].match()
		var left_check=check_match_left(column,row,color,0,0,pieces_to_delete)
		var right_check=check_match_right(column,row,color,0,0,left_check[2])
		var up_check=check_match_up(column,row,color,0,0,right_check[2])
		var down_check=check_match_down(column,row,color,0,0,up_check[2])
		pieces_to_delete=down_check[2]
		var pieces_removed=1+left_check[1]+right_check[1]+up_check[1]+down_check[1]
#		var score=pieces_removed*piece_value*streak*refill_bonus
#		if pieces_removed>3:
#			score=score+100*(pieces_removed-3)
#		if pieces_removed>=GlobalVars.min_piece_for_bonus:
#			emit_signal("update_timer",GlobalVars.num_bonus_seconds)
			
			
#		emit_signal("update_score",score)
#		var center=get_central_coordinate(pieces_to_delete)
#		var pos=grid_to_pixel(center.x,center.y)
#		var lbl_score=label.instantiate()
#		add_child(lbl_score)
#		lbl_score.move_up(pos,Color.WHITE_SMOKE)
#		streak+=1
		print ("left check:" + str(left_check))
		print ("right check:" + str(right_check))
		print ("up check:" + str(up_check))
		print ("down check:" + str(down_check))
#		print(all_matches)
		print("collections to delete:" + str(collections_to_delete))
		collections_to_delete.push_back(pieces_to_delete)
		return true
	else:
		return false

func search_match_grid():
	var matched=false
	all_matches=make_2d_array()
	for i in range (0,width):
		for j in range(0,height):
			if find_match(i,j):
				matched=true
	return matched

func print_match_grid():
	for i in range (width):
		for j in range(height):
			if all_matches[i][j]!=null:
				all_pieces[i][j].match()

func matches():
	print("matches?")
	pass
func is_in_grid(column,row):
	if column>=0 && column<width:
		if row>=0 && row<height:
			return true
	return false

func swap_pieces(column,row,direction):
	collections_to_delete=[]
	var top_ui = get_parent().get_node("top_ui")
	var prebottom_ui = get_parent().get_node("prebottom_ui/MarginContainer/lblscore")		
	var previous_position={"time":top_ui.get_time(),
						   "movements":top_ui.get_score(),
						   "score":prebottom_ui.text,
						   "grid":store_pieces(all_pieces)
						  }

	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		state=wait
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		all_matches=make_2d_array()
		var first_elem_chk=find_match(column,row)	
		var second_elem_chk=find_match(column + direction.x, row + direction.y)	
		print_match_grid()
		if first_elem_chk || second_elem_chk:
			GlobalVars.previous_position= previous_position
			get_parent().get_node("destroy_timer").start()
		else:
			# wait 0.8 seconds
			await get_tree().create_timer(0.8).timeout 
			all_pieces[column][row] = first_piece
			all_pieces[column + direction.x][row + direction.y] = other_piece
			other_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			first_piece.move(grid_to_pixel(column, row))
			state=move
			swap_back()
			

func swap_back():
	print("swap back")
		
func touch_difference(grid_1,grid_2):
			
	var difference = grid_2 - grid_1
	if abs(difference.x)>abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x,grid_1.y,Vector2(1,0))
		elif difference.x<0:
			swap_pieces(grid_1.x,grid_1.y,Vector2(-1,0))
	elif abs(difference.y)>abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x,grid_1.y,Vector2(0,1))
		elif difference.y<0:
			swap_pieces(grid_1.x,grid_1.y,Vector2(0,-1))
		
	
func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		first_touch = get_global_mouse_position()
		var pos=pixel_to_grid(first_touch.x,first_touch.y)
		print("start:" + str(pos))
		if is_in_grid(pos.x,pos.y):
			#all_matches=make_2d_array()
			#find_match(pos.x,pos.y)
			if destroy_button:
				var col_destroy=all_pieces[pos.x][pos.y].color
				destroy_pieces_color(col_destroy)
				destroy_button=false
				var btn=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_destroy")
				var btn2=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_empty")
				btn2.visible=true
				btn.disabled=false
				btn.visible=false
				pause_timer=true
				emit_signal("pause_timer_collapse",pause_timer)
				get_parent().get_node("collapse_timer").start()				
			else:
				controlling=true
		else:
			print ("off the grid")
	if Input.is_action_just_released("ui_touch"):
		final_touch = get_global_mouse_position()
		var pos=pixel_to_grid(final_touch.x,final_touch.y)
		print("end:" + str(pos))
		if is_in_grid(pos.x,pos.y) && controlling:
			touch_difference(pixel_to_grid(first_touch.x,first_touch.y),
							pixel_to_grid(final_touch.x,final_touch.y))			
			print("swipe")
		controlling=false
		var p=pixel_to_grid(first_touch.x,first_touch.y)
		if p.x==0 && p.y==0:
			magic_seq=1
		if magic_seq==1 && p.x==1 && p.y==1:
			magic_seq=2
		if magic_seq==2 && p.x==2 && p.y==2:
			magic_seq=3
		if magic_seq==3:
			emit_signal("reset_score")
			emit_signal("display_hi_score",0)
			emit_signal("display_hi_pieces",0)
			magic_seq=0

#	if Input.is_action_just_released("ui_mouse_right"):
#		spawn_pieces()
#	if Input.is_action_just_released("ui_mouse_middle"):
#		search_match_grid()
#		print_match_grid()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state==move && !end_game && !pause_game:
		touch_input()

func destroy_pieces():
	for i in width:
		for j in height:
			if all_pieces[i][j]!= null:
				all_pieces[i][j].queue_free()
				all_pieces[i][j]=null

func destroy_pieces_color(color):
	for i in width:
		for j in height:
			if all_pieces[i][j]!= null:
				if all_pieces[i][j].color==color:
					all_pieces[i][j].queue_free()
					all_pieces[i][j]=null
	
func _on_destroy_timer_timeout():
	pause_timer=true
	emit_signal("pause_timer_collapse",pause_timer)
#	pause_game=true
#	emit_signal("toggle_pause",pause_game)			
#	get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/toggle_pause").disabled=true			
	print("collection_to_delete:" + str(collections_to_delete))
	var collection=[]
	for i in range(collections_to_delete.size()):
		if collections_to_delete[i].size() > 1:
			collection.push_back(collections_to_delete[i])
	print("collection_to_delete after:" + str(collection))
	for i in collection.size():
		for j in collection[i].size():
			var coord=collection[i][j]
			var x=coord[0]
			var y=coord[1]
			all_pieces[x][y].queue_free()
			all_pieces[x][y]=null
		play_effect(snd_destroy,0)
		var pieces_removed=collection[i].size()
		var score=pieces_removed*piece_value*streak*refill_bonus
		if pieces_removed>3:
			score=score+100*(pieces_removed-3)
		emit_signal("update_score",score)
		emit_signal("update_pieces",pieces_removed)
		var center=get_central_coordinate(collection[i])
		var pos=grid_to_pixel(center.x,center.y)
		var lbl_score=label.instantiate()
		add_child(lbl_score)
		lbl_score.move_up(pos,Color.WHITE_SMOKE,str(pieces_removed))
		streak+=1
		if pieces_removed>=GlobalVars.min_piece_for_bonus and pieces_removed<GlobalVars.min_piece_extra_bonus:
			emit_signal("update_timer",GlobalVars.num_bonus_seconds)
			var lbl_timer=label.instantiate()
			add_child(lbl_timer)
			pos=grid_to_pixel(3,10)
			lbl_timer.move_up(pos,Color.INDIGO,"+" + str(GlobalVars.num_bonus_seconds) + " s")
		if pieces_removed>=GlobalVars.min_piece_extra_bonus:
			emit_signal("update_timer",GlobalVars.num_bonus_extra_seconds)
			var lbl_timer=label.instantiate()
			add_child(lbl_timer)
			pos=grid_to_pixel(3,10)
			lbl_timer.move_up(pos,Color.INDIGO,"+" + str(GlobalVars.num_bonus_extra_seconds) + " s")
		if pieces_removed>=4:
			var pieces=collection[i]
			var is_line_col=true
			var is_line_row=true
			var piece=pieces[0]
			var col=piece[0]
			var row=piece[1]
			for x in pieces.size():
				var piece_line=pieces[x]
				if  piece_line[0] != col:
					is_line_col=false	
				if piece_line[1] != row:
					is_line_row=false
			if is_line_col || is_line_row:
				print ("linea recta")
				show_destroy_button()


		if collection[i].size()>5:
			await get_tree().create_timer(.2).timeout
			play_effect(snd_addtime,0)
		await get_tree().create_timer(.2).timeout

#	for i in width:
#		for j in height:
#			if all_pieces[i][j]!= null && all_matches[i][j]!=null:
#				all_pieces[i][j].queue_free()
#				all_pieces[i][j]=null
#  	for i in collection.size():
#		play_effect(snd_destroy,i*0.5)
	get_parent().get_node("collapse_timer").start()			
	collections_to_delete=[]
	
func collapse():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j+1,height):
					if all_pieces[i][k]!=null:
						all_pieces[i][k].move(grid_to_pixel(i,j))
						all_pieces[i][j]=all_pieces[i][k]
						all_pieces[i][k]=null
						break

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j]==null:
				var rand = floor(randf_range(0,possible_pieces.size()))
				var piece = possible_pieces[rand].instantiate()
				while check_line_column(i,j,piece.color)>=3 ||check_line_row(i,j,piece.color)>=3:
						piece.queue_free()
						rand = floor(randf_range(0,possible_pieces.size()))
						piece = possible_pieces[rand].instantiate()
				add_child(piece)
				piece.position=grid_to_pixel(i,j+y_offset)
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j]=piece
	refill_bonus+=1
	streak=1

func play_effect(effect,delay):
	var sound=direct_sound.instantiate()
	add_child(sound)
	sound.add_delay(delay)
	sound.play_sound(effect)


func _on_collapse_timer_timeout():
	collapse()
	get_parent().get_node("refill_timer").start()


func _on_refill_timer_timeout():
	refill_columns()
	get_parent().get_node("recheck_timer").start()
	


func _on_recheck_timer_timeout():
	var match=search_match_grid()
	if match:
		get_parent().get_node("destroy_timer").start()
	else:
		state=move
		streak=1
		refill_bonus=1
		var m=available_movements()
		if m==0:
			get_parent().get_node("nomoves_timer").start()
		else:
			pause_timer=false
			emit_signal("pause_timer_collapse",pause_timer)
		print(all_pieces)

			
						
			
#		pause_game=false
#		emit_signal("toggle_pause",pause_game)
#		get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/toggle_pause").disabled=false			


func _on_countdown_timer_timeout():
	emit_signal("update_timer",-1)


func _on_top_ui_stop_game():
	end_game=true
	get_parent().get_node("GameOver").show()
	emit_signal("check_hi_score")

	


func _on_toggle_play_btn_pressed():
	print("play toggle")
	if pause_game:
		pause_game=false
	else:
		pause_game=true
	emit_signal("toggle_pause",pause_game)
		
		


func _on_restart_pressed():
	print("restart game")
	destroy_pieces()
	start()	


func _on_toggle_pause_pressed():
	print("pause toggle")
	if pause_game:
		pause_game=false
	else:
		pause_game=true
	emit_signal("toggle_pause",pause_game)
	


func _on_game_over_restart_game():
	get_parent().get_node("GameOver").hide()
	_on_restart_pressed()


func _on_btn_continue_pressed():
	pause_game=false
	emit_signal("toggle_pause",pause_game)


func _on_btn_options_pressed():
	var curr=GlobalVars.main_scene
	GlobalVars.last_scene=curr
	var ins_option=options.instantiate()
	var parent=curr.get_parent()
	parent.remove_child(curr)
	parent.add_child(ins_option)





func _on_toggle_pause(ispaused):
	if ispaused:
		get_parent().get_node("background/MarginContainer/texture_pause").show()			
	else:
		get_parent().get_node("background/MarginContainer/texture_pause").hide()			
	get_tree().paused=ispaused			
		

	pass # Replace with function body.


func _on_btn_restart_pressed():
	_on_btn_continue_pressed()
	GlobalVars.restart_game()





func _on_nomoves_timer_timeout():
	var a=get_parent().get_node("background/MarginContainer/margin_nomoves")
	print("node name: " + a.name)
	get_parent().get_node("background/MarginContainer/margin_nomoves").show()
	get_parent().get_node("nomoves_cont_timer").start()
	

func _on_nomoves_cont_timer_timeout():
	destroy_pieces()
	all_pieces=make_2d_array()	
	all_matches=make_2d_array()
	spawn_pieces()
	get_parent().get_node("background/MarginContainer/margin_nomoves").hide()
	pause_timer=false
	emit_signal("pause_timer_collapse",pause_timer)

func _on_rewind_timer_timeout():
	get_parent().get_node("background/MarginContainer/margin_rewind").show()
	get_parent().get_node("rewind_cont_timer").start()


func _on_rewind_cont_timer_timeout():
	destroy_pieces()
	all_matches=make_2d_array()
	var top_ui = get_parent().get_node("top_ui")
	var prebottom_ui = get_parent().get_node("prebottom_ui/MarginContainer/lblscore")		
	var previous_position=GlobalVars.previous_position
	var all_pieces_obj=previous_position["grid"]
	top_ui.set_score(previous_position["movements"])
	top_ui.set_time(previous_position["time"])
	prebottom_ui.text=previous_position["score"]
	
						#{"time":top_ui.get_time(),
						   #"movements":top_ui.get_score(),
						   #"score":prebottom_ui.text,
						   #"grid":all_pieces.duplicate(true)
						  #}


	draw_pieces(all_pieces_obj)
	get_parent().get_node("background/MarginContainer/margin_rewind").hide()
	get_tree().paused=false

func draw_pieces(obj):
	print("draw pieces")
	print(obj)
	for i in width:
		for j in height:
			var piece_name = obj[i][j]
			var piece_type = piece_types[piece_name]
			var piece=possible_pieces[piece_type].instantiate()
			all_pieces[i][j]=piece
			add_child(piece)
			piece.position=grid_to_pixel(i,j)


func _on_rewind_pressed():
	if GlobalVars.previous_position!=null:
		get_tree().paused=true
		get_parent().get_node("rewind_timer").start()

func save_status():
	var top_ui = get_parent().get_node("top_ui")
	var prebottom_ui = get_parent().get_node("prebottom_ui/MarginContainer/lblscore")		
	var fname=GlobalVars.status_file
	var stime=top_ui.get_time()
	var smov=top_ui.get_score()
	var sscor=prebottom_ui.text
	var sgrid=store_pieces(all_pieces)
	DirAccess.remove_absolute(fname)
	var config = ConfigFile.new()
	config.set_value("VALUES","TIME",stime)
	config.set_value("VALUES","MOVES",smov)
	config.set_value("VALUES","SCORE",sscor)
	var sname="PIECE{i},{j}"
	for i in width:
		for j in height:
			var piece_name = all_pieces[i][j]
			var color=piece_name.color
			var piece_type = piece_types[piece_name.color]
			var sname2=sname.format({"i":i,"j":j})
			config.set_value("PIECES",sname2,color)
	var btn=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_destroy")
	if btn.visible:
		config.set_value("VALUES","DESTROY_BUTTON",1)
	else:
		config.set_value("VALUES","DESTROY_BUTTON",0)
		
	config.save(fname)
	
func load_status():
	get_parent().get_node("load_status_timer").start()
	pass
	



func _on_load_status_timer_timeout():
	print("load status")
	var top_ui = get_parent().get_node("top_ui")
	var prebottom_ui = get_parent().get_node("prebottom_ui/MarginContainer/lblscore")		
	var fname=GlobalVars.status_file
	var config = ConfigFile.new()
	var err = config.load(fname) 
	if err == OK: 
		var stime=config.get_value("VALUES","TIME")	
		var smov=config.get_value("VALUES","MOVES")
		var sscor=config.get_value("VALUES","SCORE")
		top_ui.set_time(stime)
		top_ui.set_score(smov)
		prebottom_ui.text=sscor
		var sname="PIECE{i},{j}"
		var load_array=make_2d_array()
		for i in width:
			for j in height:
				var sname2=sname.format({"i":i,"j":j})
				var color=config.get_value("PIECES",sname2)
				load_array[i][j]=color
		destroy_pieces()
		draw_pieces(load_array)
		var ball=config.get_value("VALUES","DESTROY_BUTTON")
		var btn=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_destroy")
		if ball==1:
			btn.visible=true
		else:
			btn.visible=false

	DirAccess.remove_absolute(fname)
	pass # Replace with function body.

func show_destroy_button() -> void:
	var btn=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_destroy")
	var btn2=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_empty")
	btn.visible=true
	btn2.visible=false
	
	pass # Replace with function body.

func _on_btn_destroy_pressed() -> void:
	var btn=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_destroy")
#	var btn2=get_parent().get_node("bottom_ui/MarginContainer/HBoxContainer/btn_empty")
	btn.disabled=true
	destroy_button=true
#	btn2.visible=false
	
	pass # Replace with function body.

func reset_score_1():
	var top_ui = get_parent().get_node("top_ui")
	var prebottom_ui = get_parent().get_node("prebottom_ui/MarginContainer/lblscore")		
	top_ui.set_score("0000000")
	prebottom_ui.text="0000000"
