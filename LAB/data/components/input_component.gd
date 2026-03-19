extends Node
class_name InputComponent

var move_dir: Vector2 = Vector2.ZERO

var jump_pressed := false
var click_pressed := false
var alt_click_pressed := false



func _ready() -> void:
	print("Input Component Ready!")

func update() -> void: 
	move_dir = Input.get_vector("left", "right", "up", "down")
	print(move_dir)
	jump_pressed = Input.is_action_just_pressed("jump")
	print(jump_pressed)
	click_pressed = Input.is_action_just_pressed("left_click")
	alt_click_pressed = Input.is_action_just_pressed("right_click'")
