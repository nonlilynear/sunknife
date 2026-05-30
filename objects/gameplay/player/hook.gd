extends Node2D

@onready var p: CharacterBody2D = get_parent()
@export var max_distance: float = 1000.0
@export var pull_force: float = 30.0

@export var cooldown_label: Label

var hook_available: bool = true
var grappled: bool = false

func _ready() -> void:
	$hook_ray.target_position.y = max_distance

func _process(delta: float) -> void:
	$chain.visible = grappled
	do_chain_graphics()
	
	cooldown_label.global_position = get_global_mouse_position()
	
	if not hook_available:
		cooldown_label.text = str(int($cooldown.time_left))

func _physics_process(delta: float) -> void:
	$hook_ray.look_at(get_global_mouse_position())
	$hook_ray.rotation += 3 * PI/2
	
	if grappled: apply_grapple()

func _input(event):
	if event.is_action_pressed("hook"): 	try_grapple()
	elif event.is_action_released("hook"): release_grapple()

func try_grapple():
	if $hook_ray.is_colliding() and hook_available: begin_grapple()

func begin_grapple():
	grappled = true
	hook_available = false
	$cooldown.start()
	$tip.position = $hook_ray.get_collision_point()
	
func apply_grapple():
	p.velocity += pull_force * ($tip.position - p.global_position).normalized()

func release_grapple():
	grappled = false
	
func do_chain_graphics():
	var tip_loc = to_local($tip.global_position)
	$chain.rotation = deg_to_rad(180) + self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	$tip.rotation = self.position.angle_to_point(tip_loc) - deg_to_rad(90)
	$chain.position = tip_loc
	$chain.region_rect.size.y = tip_loc.length()

func _on_cooldown_timeout() -> void:
	hook_available = true
	cooldown_label.text = "🪝"
