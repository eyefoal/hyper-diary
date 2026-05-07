extends CharacterBody2D

enum STATE {
	FLOOR,
	JUMP,
	FALL,
	CROUCH,
	DIVE,
}

const WALK_SPEED := 300.0
const WALK_ACCELERATION := 420.0
const JUMP_HEIGHT := -500.0
const JUMP_SPEED := 300.0
const FALL_SPEED := 1000.0

var active_state := STATE.FLOOR

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	match active_state:
		STATE.FLOOR: #Floor State
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			if not is_on_floor():
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("crouch"):
				switch_state(STATE.CROUCH)
	
		STATE.JUMP:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
	
		STATE.FALL:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			if is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
		
		STATE.CROUCH:
			velocity.x *= 0.7
			if not is_on_floor():
				switch_state(STATE.FALL)
			if Input.is_action_just_released("crouch"):
				switch_state(STATE.FLOOR)
		
		STATE.DIVE:
			velocity.y += FALL_SPEED * delta
			if is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("crouch") and is_on_floor():
				switch_state(STATE.CROUCH)
	
	move_and_slide()
	
func switch_state(to_state: STATE) -> void:
	active_state = to_state
	
	match active_state:
		STATE.FLOOR:
			print("On Floor!")
		STATE.JUMP:
			velocity.y = move_toward(velocity.y, JUMP_HEIGHT, JUMP_SPEED)
			print("Jumping!")
		STATE.FALL:
			print("Falling!")
		STATE.CROUCH:
			print("Crouching")
		STATE.DIVE:
			print("Diving!")
			var direction := Input.get_axis("left", "right")
			velocity.x = direction * 1.5 * WALK_SPEED
			velocity.y = 0.5 * JUMP_HEIGHT
