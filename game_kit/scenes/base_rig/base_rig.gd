extends Node2D
class_name BaseRig

@onready var animation_rig: Node2D = %AnimationRig

var is_moving: bool = false
var walk_tween: Tween

var pulse_tween: Tween
var is_pulsing: bool = false

func _ready() -> void:
	walk_tween = Animations.walk(animation_rig, 0.1, 0.3, true)
	walk_tween.pause()

func set_animation_rig_direction(direction: Vector2) -> void:
	if direction.x > 0 and animation_rig.scale.x < 0:
		animation_rig.scale.x = abs(animation_rig.scale.x)
	elif direction.x < 0 and animation_rig.scale.x > 0:
		animation_rig.scale.x = - abs(animation_rig.scale.x)

func update_walk_animation(_velocity: Vector2):
	if _velocity == Vector2.ZERO and is_moving:
		# Logger.log_debug(self.name, "kill walk tween")
		is_moving = false
		walk_tween.pause()
		animation_rig.rotation = 0.0 
		return
	
	if _velocity != Vector2.ZERO and not is_moving:
		# Logger.log_debug(self.name, "start walk tween")
		is_moving = true
		animation_rig.rotation = 0.0
		walk_tween.play()
		return

func start_pulse_animation() -> void:
	if is_pulsing:
		return

	is_pulsing = true
	pulse_tween = Animations.pulse(animation_rig, 1.05, 1.0, true)

func stop_pulse_animation() -> void:
	if not is_pulsing:
		return

	is_pulsing = false
	pulse_tween.kill()

func fade_in(duration: float = 0.2) -> Signal:
	var tween = Animations.fade_in(animation_rig, duration)
	return tween.finished

func fade_out(duration: float = 0.2) -> Signal:
	var tween = Animations.fade_out(animation_rig, duration)
	return tween.finished

func flash(duration: float = 0.1) -> void:
	animation_rig.material.set_shader_parameter("active", true)
	await get_tree().create_timer(duration).timeout
	animation_rig.material.set_shader_parameter("active", false)
