extends State

@export var fall_state : State

@export var idle_state: State

@export var move_state: State

@export var jump_force: float = 900.0

func enter() -> void:
	super()
	body.velocity.y  = -jump_force

func process_physics(delta: float) -> State:
	body.velocity.y += gravity * delta
	
	if body.velocity.y > 0:
		return fall_state
	
	var movement = Input.get_axis("left", "right") + move_speed
	
	if movement != 0:
		body.velocity.x = movement
		body.move_and_slide()
	
	if body.is_on_floor():
		return move_state
	return idle_state
