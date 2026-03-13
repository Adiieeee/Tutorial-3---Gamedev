extends CharacterBody2D

@export var SPEED := 40
@export var GRAVITY := 800
@export var MAX_HEALTH := 3
@export var ATTACK_DAMAGE := 1
@export var ATTACK_COOLDOWN := 1.0

@onready var animplayer = $AnimatedSprite2D
@onready var enemy_sfx = $EnemySFX
@onready var detection_area = $DetectionArea

var health := MAX_HEALTH
var is_dead := false
var is_hurt := false
var attack_timer := 0.0
var player: CharacterBody2D = null
var player_detected := false

func _ready():
	animplayer.animation_finished.connect(_on_animation_finished)
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _on_animation_finished():
	if is_dead:
		queue_free()
		return
	if is_hurt:
		is_hurt = false

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_detected = true

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_detected = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += delta * GRAVITY
	attack_timer -= delta

	_handle_movement()
	move_and_slide()
	_check_player_collision()
	_update_animation()

func _handle_movement():
	if player == null or not player_detected or is_hurt:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return

	var direction = sign(player.global_position.x - global_position.x)
	velocity.x = SPEED * direction
	animplayer.flip_h = direction < 0

func _check_player_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer <= 0:
				collider.take_damage(ATTACK_DAMAGE)
				attack_timer = ATTACK_COOLDOWN
				enemy_sfx.play()

func _update_animation():
	if is_hurt:
		return
	if abs(velocity.x) > 0:
		animplayer.play("walk")
	else:
		animplayer.play("idle")

func take_damage(amount: int):
	if is_dead or is_hurt:
		return

	health -= amount
	if health <= 0:
		die()
	else:
		is_hurt = true
		velocity.x = 0
		animplayer.stop()
		animplayer.play("hurt")

func die():
	is_dead = true
	velocity.x = 0
	animplayer.stop()
	animplayer.play("die")
	await animplayer.animation_finished
	queue_free()
