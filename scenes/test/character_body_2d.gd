extends CharacterBody2D

var speed: float = 700.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("action_main"):
		var mouse_position = get_global_mouse_position()
		navigation_agent_2d.target_position = mouse_position
		

	if navigation_agent_2d.is_target_reachable() and not navigation_agent_2d.is_target_reached():
		var next_position = navigation_agent_2d.get_next_path_position()
		
		if not next_position:
			return
			
		var direction = global_position.direction_to(next_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
	else:
		velocity = Vector2.ZERO
