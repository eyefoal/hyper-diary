extends Sprite2D
class_name LabShaderTest

func _ready() -> void:
	var tween = create_tween();
	tween.tween_property(material, "shader_parameter/fade", 1.0, 1.0);
