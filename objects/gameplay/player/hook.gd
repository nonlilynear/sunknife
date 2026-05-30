extends Node2D

@onready var p: CharacterBody2D = get_parent()
@export var max_distance: float = 1000.0
@export var pull_force: float = 30.0

var grappled: bool = false

func _ready() -> void:
	$hook_ray.target_position.y = max_distance

func _physics_process(delta: float) -> void:
	$hook_ray.look_at(get_global_mouse_position())
	$hook_ray.rotation += 3 * PI/2
	
	if grappled: apply_grapple()

func _input(event):
	if event.is_action_pressed("hook"): 	try_grapple()
	elif event.is_action_released("hook"): release_grapple()

func try_grapple():
	if $hook_ray.is_colliding(): begin_grapple()

func begin_grapple():
	grappled = true
	$tip.position = $hook_ray.get_collision_point()
	
func apply_grapple():
	p.velocity += pull_force * ($tip.position - p.global_position).normalized()

func release_grapple():
	grappled = false
