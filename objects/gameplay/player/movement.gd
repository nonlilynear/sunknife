# movement component script for CharacterBody2D
extends Node2D

@onready var p: CharacterBody2D = get_parent() # reference to player node
@onready var ground_ray: ShapeCast2D = $ground_ray # ground detection ray
@export var sprite: AnimatedSprite2D # sprite to animate (optional)
var animated: bool = false # configured automatically based on `sprite`

# input variables
var input_dir: Vector2 = Vector2.ZERO # max magnitude 1.0
var jump_just_pressed: bool = false

# movement constants - pixels per second
@export_group("movement configuration")
@export_subgroup("ground movement")
@export var start_accel: float = 100
@export var stop_accel: float = 50
@export var max_speed: float = 200

@export_subgroup("jump tuning")
var jump_speed: float = 300 # calculated from height
@export var jump_height: float = 48: # height in pixels
	set(value):
		jump_height = value
		jump_speed = calculate_jump(value)
@export var sticky_distance: float = 20: # how close to the ground we can jump
	set(value):
		sticky_distance = value
		if ground_ray: ground_ray.target_position.y = value
@export var coyote_duration: float = 0.1 # for how long can we jump after falling
var coyote_timer: float = coyote_duration

@export_subgroup("air movement")
@export var first_half_grav: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var second_half_grav: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var air_strafe_multiplier: float = 0.2
var dashing: bool = false

# runs when the scene is ready--initial configuration
func _ready():
	animated = sprite != null
	jump_speed = calculate_jump(jump_height)
	ground_ray.target_position = Vector2(0, sticky_distance)

# runs every frame
func _process(delta):
	pass

# runs every physics frame (60 times per second)
func _physics_process(delta):
	# collect inputs (check Project Settings -> Input Map)
	## the direction the player wants to move--gathered from buttons or joystick
	input_dir.x = clamp(Input.get_axis("left", "right"), -1.0, 1.0)
	
	## whether the player pressed jump this frame
	jump_just_pressed = Input.is_action_just_pressed("jump")
	
	# convert inputs into movement
	update_velocities(input_dir, jump_just_pressed, delta)
	p.move_and_slide()
	
	# animate the sprite accordingly
	if animated: animate(input_dir.x, p.is_on_floor(), sprite)

# update character velocities for one frame based on inputs
func update_velocities(dir: Vector2, jump: bool, delta: float):
	# stuff to do every frame
	## gravity
	if not dashing:
		if (p.velocity.y < 0): # going up
			p.velocity.y += first_half_grav * delta
		else:                  # going down 
			p.velocity.y += second_half_grav * delta
	
	## decrement coyote timer every frame
	coyote_timer -= delta
	
	# horizontal movement
	## multiply movespeed if air-strafing
	var multiplier = 1.0 if ground_ray.is_colliding() else air_strafe_multiplier
	
	var modified_max_speed: float = max_speed
	if dashing: modified_max_speed *= 2
	
	if dir:
		# change directions at start rate
		# makes counterstrafing possible
		p.velocity.x = lerpf(p.velocity.x, 
							 dir.x * modified_max_speed, 
							 start_accel / modified_max_speed * multiplier)
	else:
		# only use stop rate for stopping
		p.velocity.x = lerpf(p.velocity.x, 0, 
							 stop_accel / modified_max_speed * multiplier)

	# jumping
	## reset coyote timer when on the ground
	if ground_ray.is_colliding() and p.velocity.y > 0:
		coyote_timer = coyote_duration
	
	## jump !
	if jump and coyote_timer > 0:
		p.velocity.y = -jump_speed
		coyote_timer = 0

# call this to make the player stop moving
# (until they provide another input)
func cancel_movement():
	p.velocity = Vector2.ZERO

# calculate jump velocity based on desired jump height
func calculate_jump(jump_height: float):
	return sqrt(2 * first_half_grav * jump_height)

# animate sprite based on status
# expects "run", "idle", and "jump" animations
func animate(x_input: float, on_floor: bool, sprite: AnimatedSprite2D):
	if abs(x_input) > 0: sprite.play("run")
	else: sprite.play("idle")
	
	if x_input > 0: sprite.flip_h = true
	elif x_input < 0: sprite.flip_h = false
	
	if !on_floor: sprite.play("jump")
