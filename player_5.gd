extends CharacterBody2D

@export var SPEED := 200
@export var JUMP_SPEED := -420
@export var GRAVITY := 1200
@onready var animplayer = $AnimatedSprite2D

const UP = Vector2(0,-1)

func _get_input():
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_SPEED

  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	var animation = "idle"
	if direction:
		animation = "jalan_kanan"
		velocity.x = direction * SPEED
		if direction>0:
			animplayer.flip_h = false
		else:
			animplayer.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if animplayer.animation!=animation:
		animplayer.play(animation)

	move_and_slide()

func _physics_process(delta: float) -> void:
	velocity.y += delta*GRAVITY
	_get_input()
	move_and_slide()
