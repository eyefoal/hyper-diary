extends CharacterBody2D
class_name LabPlayer2D

@export_category("Parameters")
@export var SPEED := 300.0
@export var FALL_SPEED := 650.0
@export var WEIGHT := 10.0 
@export var JUMP_VELOCITY := -400.0
@export var JUMP_SPEED := 400.0
@export var JUMP_CUT : float

func _ready() -> void:
	print("Hello Worlds!")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += FALL_SPEED * delta 

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = move_toward(velocity.y, JUMP_VELOCITY, JUMP_SPEED)
	
	#Handle jump cut.
	if Input.is_action_just_released("ui_accept") and not is_on_floor():
		velocity.y = JUMP_CUT * WEIGHT

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
