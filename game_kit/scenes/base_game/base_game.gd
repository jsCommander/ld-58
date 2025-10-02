extends Node
class_name BaseGame 

@export var transition_time: float = 0.5

@onready var scene_root: Node2D = %SceneRoot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var canvas_layer: CanvasLayer = %CanvasLayer

var current_scene: PackedScene
var current_scene_instance: Node

func _ready():
	add_to_group("Game")
	canvas_layer.visible = false

	Logger.log_info(self.name, "Initialized")

func load_scene(scene: PackedScene):
	var scene_name = scene.resource_path
	Logger.log_info(self.name, "Starting to load level: %s" % scene_name)
		
	if current_scene_instance:
		var current_scene_name = current_scene_instance.name
		Logger.log_info(self.name, "Removing current scene: %s" % current_scene_name)
		_start_transition()
		current_scene_instance.queue_free()
		await current_scene_instance.tree_exiting
		Logger.log_debug(self.name, "Current scene was removed: %s" % name)
		await get_tree().create_timer(transition_time).timeout
		
	var scene_instance = scene.instantiate()
	Logger.log_debug(self.name, "Scene is created: %s" % scene_name)
	scene_root.call_deferred("add_child", scene_instance)
	Logger.log_info(self.name, "Scene is active: %s" % scene_name)

	current_scene = scene
	current_scene_instance = scene_instance
	
	if scene_instance is BaseGameScene:
		scene_instance.finished.connect(handle_scene_finished)
		scene_instance.reload_requested.connect(handle_scene_reload_requested)
	
	_end_transition()

func handle_scene_finished(_data: Dictionary):
	Logger.log_info(self.name, "Scene %s finished with data: %s" % [current_scene_instance.name, _data])

func handle_scene_reload_requested(_data: Dictionary):
	Logger.log_info(self.name, "Scene %s reload requested with data: %s" % [current_scene_instance.name, _data])
	load_scene(current_scene)

func _start_transition():
	canvas_layer.visible = true
	animation_player.play('fade_in')

func _end_transition():
	animation_player.play('fade_out')
	await animation_player.animation_finished
	canvas_layer.visible = false
