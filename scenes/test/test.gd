@tool
extends Node2D

@export var legsTexture: Texture2D
@export var bodyTexture: Texture2D
@export var headTexture: Texture2D

@onready var legs: Sprite2D = %Legs
@onready var body: Sprite2D = %Body
@onready var head: Sprite2D = %Head

func _process(delta: float) -> void:
	legs.texture = legsTexture
	body.texture = bodyTexture
	head.texture = headTexture
