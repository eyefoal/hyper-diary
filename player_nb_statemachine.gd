extends CharacterBody2D
class_name NBPlayer

@onready var state_machine = $StateMachine

func _ready() -> void:
	state_machine._init(self)
