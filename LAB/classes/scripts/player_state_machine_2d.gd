extends CharacterBody2D
class_name PlayerStateMachine

enum STATE {
	FLOOR,
	JUMP,
	PLUS_JUMP,
	FALL,
	CROUCH,
	CROUCH_JUMP,
	DIVE,
}

const WALK_SPEED := 250.0
const WALK_ACCELERATION := 600.0
const FRICTION := 500.0
const JUMP_HEIGHT := -640.0
const PJUMP_HEIGHT := -280.0
const CROUCH_JUMP := -220.0
const JUMP_SPEED := 300.0
const FALL_SPEED := 720.0

@export var max_jumps := 1
var jumps : int
var can_double_jump : bool

var active_state := STATE.FLOOR

func _ready() -> void:
	jumps = max_jumps
	can_double_jump = true

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	
	if jumps == 0:
		can_double_jump = false
	
	match active_state:
		STATE.FLOOR: #Floor State
			if direction:
				velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			if not is_on_floor():
				switch_state(STATE.FALL)
			
			if Input.is_action_pressed("crouch") and is_on_floor():
				switch_state(STATE.CROUCH)
			can_double_jump = true
	
		STATE.JUMP:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			
			if Input.is_action_just_released("jump") or velocity.y >= 0:
				velocity.y = 0
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
		
		STATE.PLUS_JUMP:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			if velocity.y >= 0:
				switch_state(STATE.FALL)
				
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
			
		STATE.FALL:
			if direction:
				velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
			
			velocity.y += FALL_SPEED * delta
			
			if is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
		
		STATE.CROUCH:
			#velocity.x *= 0.7
			if direction:
				velocity.x = move_toward(velocity.x, direction * (WALK_SPEED / 2), WALK_ACCELERATION * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, WALK_ACCELERATION * delta) #Maybe a crawl state?
			if not is_on_floor():
				switch_state(STATE.FALL)
			if Input.is_action_just_released("crouch"):
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.CROUCH_JUMP)
		
		STATE.CROUCH_JUMP:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			if Input.is_action_just_released("jump"):
				switch_state(STATE.FALL)
			
			if Input.is_action_pressed("crouch") and is_on_floor():
				switch_state(STATE.CROUCH)
				
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
		STATE.DIVE:
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			velocity.y += FALL_SPEED * delta
			if is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_pressed("crouch") and is_on_floor():
				switch_state(STATE.CROUCH)
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
			
	move_and_slide()
	
func switch_state(to_state: STATE) -> void: #Actions only done once upon switching state.
	active_state = to_state
	
	match active_state:
		STATE.FLOOR:
			jumps = max_jumps
			print("On Floor!")
		
		STATE.JUMP:
			velocity.y = move_toward(velocity.y, JUMP_HEIGHT, JUMP_SPEED)
			print("Jumping!")
		
		STATE.PLUS_JUMP:
			velocity.y = PJUMP_HEIGHT
			jumps -= 1
			print("Double Jump!")
		
		STATE.FALL:
			print("Falling!")
			
		STATE.CROUCH:
			velocity.x = move_toward(velocity.x, 0, 2)
			print("Crouching")
			
		STATE.CROUCH_JUMP:
			print("Crouch Jumping!")
			velocity.y = move_toward(velocity.y, CROUCH_JUMP, JUMP_SPEED)
			
		STATE.DIVE:
			print("Diving!")
			var direction := Input.get_axis("left", "right")
			velocity.x = move_toward(velocity.x, direction * WALK_SPEED, WALK_ACCELERATION)
			velocity.y = 0.4 * JUMP_HEIGHT
