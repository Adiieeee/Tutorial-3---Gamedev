extends CharacterBody2D

@export var gravity = 500.0
@export var walk_speed = 300
@export var jump_speed = -410
@onready var anim = $AnimationWalk
@onready var sprite = $Sprite2D
@onready var col_standing = $CollisionStanding
@onready var col_crouching = $CollisionCrouching
var jumpcount = 2
var is_crouching = false
@export var dash_speed = 800       
@export var dash_duration = 0.2    
var is_dashing = false             
var dash_timer = 0.0               
var dash_direction = 1             

func _physics_process(delta):
	if is_dashing:
		dash_timer -= delta     
		velocity.y = 0
		velocity.x = dash_direction * dash_speed
		anim.play("dash")
		if dash_direction == 1:
			sprite.flip_h = true  
		else:                   
			sprite.flip_h = false        
		if dash_timer <= 0:
			is_dashing = false
	
	else:
		velocity.y += delta * gravity
		
		#Jump
		if jumpcount > 0 and Input.is_action_just_pressed("move_up"):
			velocity.y = jump_speed
			jumpcount -= 1

		#Animation Jump
		if not is_on_floor():
			if velocity.y < 0:
				anim.play("jump")
			elif velocity.y > 0:
				anim.play("fall")
		elif velocity.y == 0 and is_on_floor():
			anim.stop()
			
		#Jumpcount reset
		if is_on_floor():
			jumpcount = 2

		#Walk
		if Input.is_action_pressed("move_left"):
			velocity.x = -walk_speed
			sprite.flip_h = true
			if is_on_floor():
				anim.play("walk")
		elif Input.is_action_pressed("move_right"):
			velocity.x = walk_speed
			sprite.flip_h = false
			if is_on_floor():
				anim.play("walk")
		else:
			velocity.x = 0
			if is_on_floor():
				anim.play("idle")
			anim.stop()
			
		#dash
		if Input.is_action_just_pressed("dash"):
			is_dashing = true
			dash_timer = dash_duration
			dash_direction = -1 if sprite.flip_h else 1

	# "move_and_slide" already takes delta time into account.
	move_and_slide()
