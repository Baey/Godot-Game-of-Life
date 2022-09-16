extends Node2D

var cells = []
var cellsLifeDuration = []

var grid_size = Vector2(0, 0)
const CAMERA_INITIAL_POSITION = Vector2(512, 300)
const CELL_SIZE = 32
var CELL = load("res://Cell.tscn")

func _ready():
	pass

func start_stop():
	if $Timer.is_stopped():
		$Timer.start()
		$CanvasLayer/Pause.visible = false
	else:
		$Timer.stop()
		$CanvasLayer/Pause.visible = true
		
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		start_stop()
	if event is InputEventMouseButton:
		var snapped_position = get_global_mouse_position().snapped(Vector2.ONE * CELL_SIZE)
		print(snapped_position)
		if not snapped_position in cells:
			cells.append(snapped_position)
			cellsLifeDuration.append(0)
			place_cell(snapped_position)
	
func kill_over_or_unerpopulated():
	var new_cells = cells.duplicate()
	for cell in cells:
		var neighbours_count = count_neighbours(cell)
		if neighbours_count != 2 and neighbours_count != 3:
			var i = new_cells.find(cell)
			new_cells.erase(cell)
			cellsLifeDuration.remove(i)
			kill_cell(cell)
	return new_cells
			
func revive_cells():
	var new_cells = []
	var newCellsDuration = []
	for x in range(0, grid_size.x, CELL_SIZE):
		for y in range(0, grid_size.y, CELL_SIZE):
			var neighbours_count = count_neighbours(Vector2(x, y))
			if neighbours_count == 3:
				new_cells.append(Vector2(x, y))
				newCellsDuration.append(0)
				place_cell(Vector2(x, y))
	return new_cells
			
func count_neighbours(cell: Vector2) -> int:
	var neighbours_count = 0
	for x in [-CELL_SIZE, 0, CELL_SIZE]:
		for y in [-CELL_SIZE, 0, CELL_SIZE]:
			if Vector2(cell.x + x, cell.y + y) in cells and [x, y] != [0, 0]:
				neighbours_count += 1
	return neighbours_count
	
func place_cell(cell_coord: Vector2):
	var cell = CELL.instance()
	cell.position = cell_coord
	add_child(cell)
	move_child($MainCamera, $MainCamera.get_index() + 1)
	if cell_coord.x > grid_size.x - 2 * CELL_SIZE:
		grid_size.x = cell_coord.x + 2 * CELL_SIZE
	if cell_coord.y > grid_size.y - 2 * CELL_SIZE:
		grid_size.y = cell_coord.y + 2 * CELL_SIZE

func _on_Timer_timeout():
	if len(cells) != 0:
		var new_cells = kill_over_or_unerpopulated()
		new_cells += revive_cells()
		cells = new_cells.duplicate()
	$Timer.start()
	
func kill_cell(cell: Vector2):
	for child in get_children():
		if child.get_class() == "Sprite":
			if child.position == cell:
				remove_child(child)

func _on_Button_pressed():
	get_tree().reload_current_scene() # Replace with function body.

func _on_StepSlider_value_changed(value):
	$Timer.wait_time = value
