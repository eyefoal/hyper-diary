extends Node
class_name MovementStateMachine

@export var body : CharacterBody2D

enum STATE {
	FLOOR,
	JUMP,
	PLUS_JUMP,
	FALL,
	CROUCH,
	CROUCH_JUMP,
	DIVE,
	WALL_JUMP,
	WALL_SLIDE,
}

@export_category("Movement Parameters")
@export var WALK_SPEED := 250.0
@export var WALK_ACCELERATION := 500.0
@export var FRICTION := 500.0
@export var JUMP_HEIGHT := -600.0
@export var JUMP_SPEED := 300.0
@export var PJUMP_HEIGHT := -280.0
@export var FALL_SPEED := 720.0
@export var CROUCH_JUMP := -220.0
@export var WALL_JUMP := -480.0
@export var WALL_PUSH := 250.0
@export var WALL_SPEED := .0


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
	elif jumps >= 0:
		can_double_jump = true
	
	
	match active_state:
		STATE.FLOOR: #Floor State
			if direction:
				body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED,  WALK_ACCELERATION * delta)
			else:
				body.velocity.x = move_toward(body.velocity.x, 0.0, FRICTION * delta)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			if not body.is_on_floor():
				switch_state(STATE.FALL)
			
			if Input.is_action_pressed("crouch") and body.is_on_floor():
				switch_state(STATE.CROUCH)
			can_double_jump = true
	
		STATE.JUMP:
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			body.velocity.y += FALL_SPEED * delta
			
			if Input.is_action_just_released("jump") or body.velocity.y >= 0:
				body.velocity.y = 0
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
		
		STATE.PLUS_JUMP:
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			body.velocity.y += FALL_SPEED * delta
			if body.velocity.y >= 0:
				switch_state(STATE.FALL)
				
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
			
		STATE.FALL:
			if direction:
				body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			else:
				body.velocity.x = move_toward(body.velocity.x, 0.0, FRICTION * delta)
			
			body.velocity.y += FALL_SPEED * delta
			
			if body.is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
			if body.is_on_wall():
				switch_state(STATE.WALL_SLIDE)
		
		STATE.CROUCH:
			#body.velocity.x *= 0.7
			if direction:
				body.velocity.x = move_toward(body.velocity.x, direction * (WALK_SPEED / 2), WALK_ACCELERATION * delta)
			else:
				body.velocity.x = move_toward(body.velocity.x, 0.0, WALK_ACCELERATION * delta) #Maybe a crawl state?
			if not body.is_on_floor():
				switch_state(STATE.FALL)
			if Input.is_action_just_released("crouch"):
				switch_state(STATE.FLOOR)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.CROUCH_JUMP)
		
		STATE.CROUCH_JUMP:
			body.velocity.x = move_toward(body.velocity.x, direction * (WALK_SPEED * 1.67), WALK_ACCELERATION * delta)
			body.velocity.y += FALL_SPEED * delta
			if Input.is_action_just_released("jump"):
				switch_state(STATE.FALL)
			
			if Input.is_action_pressed("crouch") and body.is_on_floor():
				switch_state(STATE.CROUCH)
				
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
			
			if body.is_on_wall():
				switch_state(STATE.WALL_SLIDE)
				
		STATE.DIVE:
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			body.velocity.y += FALL_SPEED * delta
			if body.is_on_floor():
				switch_state(STATE.FLOOR)
			if Input.is_action_pressed("crouch") and body.is_on_floor():
				switch_state(STATE.CROUCH)
			if Input.is_action_just_pressed("jump") and can_double_jump:
				switch_state(STATE.PLUS_JUMP)
			if body.is_on_wall():
				switch_state(STATE.WALL_SLIDE)
		
		STATE.WALL_JUMP:
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			body.velocity.y += FALL_SPEED * delta
			
			if Input.is_action_just_released("jump") or body.velocity.y >= 0:
				body.velocity.y = 0
				switch_state(STATE.FALL)
			
			if Input.is_action_just_pressed("crouch") and direction:
				switch_state(STATE.DIVE)
			if body.is_on_floor():
				switch_state(STATE.FLOOR)
			if body.is_on_wall():
				switch_state(STATE.WALL_SLIDE)
		
		STATE.WALL_SLIDE:
			
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION * delta)
			body.velocity.y += WALL_SPEED * delta
			if body.is_on_floor():
				switch_state(STATE.FLOOR)
			if !body.is_on_wall():
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("jump") and direction:
				switch_state(STATE.WALL_JUMP)
				
	body.move_and_slide()
	
func switch_state(to_state: STATE) -> void: #Actions only done once upon switching state.
	var direction := Input.get_axis("left", "right")
	active_state = to_state
	
	match active_state:
		STATE.FLOOR:
			jumps = max_jumps
			print("On Floor!")
		
		STATE.JUMP:
			body.velocity.y = move_toward(body.velocity.y, JUMP_HEIGHT, JUMP_SPEED)
			print("Jumping!")
		
		STATE.PLUS_JUMP:
			body.velocity.y += PJUMP_HEIGHT
			jumps -= 1
			print("Double Jump!")
		
		STATE.FALL:
			print("Falling!")
			
		STATE.CROUCH:
			body.velocity.x = move_toward(body.velocity.x, 0, get_process_delta_time())
			print("Crouching")
			
		STATE.CROUCH_JUMP:
			print("Crouch Jumping!")
			body.velocity.y = move_toward(body.velocity.y, CROUCH_JUMP, JUMP_SPEED)
			
		STATE.DIVE:
			print("Diving!")
			body.velocity.x = move_toward(body.velocity.x, direction * WALK_SPEED, WALK_ACCELERATION)
			body.velocity.y = 0.2 * JUMP_HEIGHT
		
		STATE.WALL_JUMP:
			print("Wall jump!")
			body.velocity.y = move_toward(body.velocity.y, WALL_JUMP, JUMP_SPEED)
			body.velocity.x = -direction * WALL_PUSH
		
		STATE.WALL_SLIDE:
			jumps = max_jumps
			print("Slidin' down.")
