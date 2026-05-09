extends State

@export var fall_state : State

@export var jump_state : State

@export var move_state : State

func enter() -> void:
	super()
	body.velocity.x = 0

func process_input(event: InputEvent) -> State:
	if Input.is_action_just_pressed("jump") and body.is_on_floor():
		return jump_state
	if Input.get_axis("left", "right"):
		return move_state 

func process_physics(delta: float) -> State:
	body.velocity.y += gravity * delta
	body.move_and_slide()
	
	if !body.is_on_floor():
		return fall_state
	return null
