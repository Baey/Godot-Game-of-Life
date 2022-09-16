extends Camera2D


var mouse_start_pos
var screen_start_position

var dragging = false


func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed('ui_right_click'):
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_position
	if event is InputEventMagnifyGesture:
		zoom /= event.factor
		print(zoom)
