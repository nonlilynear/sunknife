extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
@export var player : CharacterBody2D

func _ready() -> void:
	velocity.x = SPEED
	player = get_parent().get_parent().get_child(0)

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if $ReiCastDown.is_colliding() == true: ##there is ground beneath you
			pass
		else:
			#print("nothing below")
			velocity.x = velocity.x * -1 ##flip around if there is nothing underneath u
		
		if $ReiCastLeft.is_colliding() == true:
			#print("hit wall on left")
			velocity.x = SPEED
		if $ReiCastRight.is_colliding() == true:
			#print("hit wall on right")
			velocity.x = SPEED*-1
		if player != null && $ReiCastup.get_collider() == player:
			velocity.y = velocity.y - 400
	move_and_slide()
	
