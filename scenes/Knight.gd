extends CharacterBody2D
@export var SPEED := 120
@export var JUMP_SPEED := -350
@export var GRAVITY := 800
@onready var animplayer = $AnimatedSprite2D
@onready var footstep_sfx = $FootstepSFX
@onready var attack_sfx = $AttackSFX
@onready var attack_hitbox = $AttackHitbox
var footstep_timer := 0.0
@export var footstep_interval := 0.5
const UP = Vector2(0,-1)
var jump_count := 0
const MAX_JUMPS := 2
var is_running := false
var is_attacking := false
var attack_combo := 0
var next_attack_buffered := false
@export var MAX_HEALTH := 5
var health := MAX_HEALTH
var is_dead := false
var is_hurt := false

func _ready():
	animplayer.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _enable_attack_hitbox():
	# Posisi hitbox mengikuti arah hadap player
	attack_hitbox.position.x = 30 if !animplayer.flip_h else -30
	attack_hitbox.monitoring = true

func _disable_attack_hitbox():
	attack_hitbox.monitoring = false

func _on_attack_hitbox_body_entered(body):
	print("hitbox mengenai: ", body.name)     # ← cek apakah hitbox mengenai sesuatu
	if body.is_in_group("enemy"):
		print("enemy terkena!")               # ← cek apakah enemy terdeteksi
		body.take_damage(1)

func _on_animated_sprite_2d_animation_finished():
	if is_hurt:
		is_hurt = false
		return
	if is_dead:
		return

	if is_attacking:
		if next_attack_buffered:
			next_attack_buffered = false
			attack_combo = (attack_combo % 3) + 1
			animplayer.stop()
			animplayer.play("attack" + str(attack_combo))
			attack_sfx.play()
			_enable_attack_hitbox()
		else:
			is_attacking = false
			attack_combo = 0
			_disable_attack_hitbox()

func take_damage(amount: int):
	if is_dead or is_hurt:
		return

	health -= amount
	print("Player health: ", health)

	if health <= 0:
		die()
	else:
		is_hurt = true
		is_attacking = false
		next_attack_buffered = false
		_disable_attack_hitbox()
		animplayer.stop()
		animplayer.play("hurt")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	_disable_attack_hitbox()
	animplayer.stop()
	animplayer.play("die")
	await animplayer.animation_finished
	queue_free()

func _get_input():
	if is_dead or is_hurt:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return

	if is_on_floor():
		jump_count = 0

	if Input.is_action_just_pressed("move_up") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_SPEED
		jump_count += 1
		animplayer.stop()
		animplayer.play("jump")

	if Input.is_action_just_pressed("attack"):
		if not is_attacking:
			is_attacking = true
			attack_combo = (attack_combo % 3) + 1
			animplayer.stop()
			animplayer.play("attack" + str(attack_combo))
			attack_sfx.play()
			_enable_attack_hitbox()
		else:
			next_attack_buffered = true

	is_running = Input.is_action_pressed("dash")
	var direction := Input.get_axis("move_left", "move_right")

	var current_speed: float
	if is_attacking:
		current_speed = SPEED * 0.5
	elif is_running:
		current_speed = SPEED * 1.6
	else:
		current_speed = SPEED

	if direction:
		velocity.x = direction * current_speed
		if direction > 0:
			animplayer.flip_h = false
		else:
			animplayer.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	if not is_attacking:
		var animation = "idle"
		if not is_on_floor():
			animation = "jump"
		elif direction and is_running:
			animation = "run"
		elif direction:
			animation = "walk"

		if animplayer.animation != animation:
			animplayer.play(animation)

		if animation == "walk" or animation == "run":
			footstep_timer -= get_physics_process_delta_time()
			if footstep_timer <= 0:
				footstep_sfx.play()
				if animation == "run":
					footstep_timer = footstep_interval * 0.8
				else:
					footstep_timer = footstep_interval
		else:
			footstep_sfx.stop()
			footstep_timer = 0.0

func _physics_process(delta: float) -> void:
	velocity.y += delta * GRAVITY
	_get_input()
	move_and_slide()
