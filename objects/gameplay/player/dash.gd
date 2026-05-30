extends Node2D

@onready var p: CharacterBody2D = get_parent()

@export var dash_power_x: float = 450.0
@export var dash_power_y: float = 310.0

const DASH_DURATION: float = 0.15
var dash_timer: float = 0
var dash_available: bool = false

func _physics_process(delta: float) -> void:
	dash_timer -= delta
	p.get_node("movement").dashing = dash_timer > 0
	if p.get_node("movement").get_node("ground_ray").is_colliding(): dash_available = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"): 
		var dash_dir = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
		if dash_dir != Vector2.ZERO and dash_available: dash(dash_dir)

func dash(dash_dir: Vector2):
	dash_available = false
	dash_timer = DASH_DURATION
	var dash_dir_ = dash_dir.normalized()
	p.velocity.x = dash_dir_.x * dash_power_x
	p.velocity.y = dash_dir_.y * dash_power_y
