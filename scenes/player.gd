extends KinematicBody2D

enum State {
	# Player can be controlled.
	CONTROLLABLE,
	# Player is in a non-gameplay "starting level" or "ending level" animation.
	ANIMATING,
	# Player is in a cutscene,
	CUTSCENE,
}

# The current state of the player.
var state = State.CONTROLLABLE
var previous_state = state

# Tracking variables for vertical and horizontal sprite flipping.
export (bool) var facing_right = true
# Either 1.0 if player is right-side-up, or -1.0 if player is upside down.
var orientation_multiplier = 1

# Movement state.
var velocity = Vector2.ZERO
var is_moving = false
var is_airborne = false
var was_airborne = false
var is_fast_falling = false

const HORIZONTAL_VEL = 75.0
const HORIZONTAL_ACCEL = 20 # How quickly we accelerate to max speed

const GRAVITY = 6.0
const GRAVITY_DECREASE_THRESHOLD = 10 # The speed below which gravity is decreased.
const GRAVITY_DECREASE_MULTIPLIER = 0.5 # The amount of decrease for low gravity (at the height of a jump).
const JUMP_VEL = 160
const TERM_VEL = JUMP_VEL * 2
const FAST_FALL_MULTIPLIER = 1.7 # How much faster fast fall is compared to gravity
const JUMP_RELEASE_MULTIPLIER = 0.5 # Multiplied by velocity if button released during the initial part of the jump.

# Squash and stretch
var squash_stretch_scale = Vector2.ONE
const JUMP_SQUASH_STRETCH = Vector2(0.8, 1.2)
const LAND_SQUASH_STRETCH = Vector2(1.5, 0.4)
const SQUASH_LERP_SPEED = 10


func _ready():
	add_to_group("player")
	_update_sprite_flip()

func _physics_process(delta):
	if state != State.CONTROLLABLE:
		return
		
	if Input.is_action_just_pressed("debug"):
		_flip_orientation()

	_animate_squash_stretch(delta)
	_move_player(delta)
	_update_sprite_flip()

func _move_player(delta):
	was_airborne = is_airborne

	var target_horizontal = 0
	var fall_multiplier = 1.0
	is_moving = false

	if Input.is_action_pressed("move_left"):
		target_horizontal -= HORIZONTAL_VEL
		is_moving = true
	if Input.is_action_pressed("move_right"):
		target_horizontal += HORIZONTAL_VEL
		is_moving = true

	if Input.is_action_just_pressed("jump") and _is_on_surface():
		_jump()
	
	if target_horizontal != 0:
		facing_right = target_horizontal > 0

	# Apply gravity and fast falling
	if is_airborne and Input.is_action_just_released("jump"):
		is_fast_falling = true
		if velocity.y * orientation_multiplier < 0:
			velocity.y *= JUMP_RELEASE_MULTIPLIER

	if is_fast_falling:
		fall_multiplier = FAST_FALL_MULTIPLIER

	# When we're nearing the top of the jump, decrease gravity.
	var grav_multiplier = 1.0 if is_fast_falling or abs(velocity.y) > GRAVITY_DECREASE_THRESHOLD else GRAVITY_DECREASE_MULTIPLIER
	# TODO: Probably need to do something other than min/max if we want arbitrary momentum puzzles.
	velocity.y = max(-TERM_VEL, min(TERM_VEL, velocity.y + GRAVITY * grav_multiplier * fall_multiplier * orientation_multiplier))

	# Lerp horizontal movement
	velocity.x = lerp(velocity.x, target_horizontal, HORIZONTAL_ACCEL * delta)

	velocity = move_and_slide(velocity, Vector2.UP)
	
	if was_airborne and _is_on_surface():
		_landed()
	elif !was_airborne and !_is_on_surface():
		# Fell off a cliff.
		is_airborne = true

	if !is_airborne:
		if is_moving:
			#$animation.play("run")
			pass
		else:
			#$animation.play("idle")
			pass

func _jump():
	is_airborne = true
	is_fast_falling = false
	velocity.y = -JUMP_VEL * orientation_multiplier
	#$animation.play("jump")
	_apply_jump_squash_stretch()

func _landed():
	is_airborne = false

func _is_on_surface():
	if orientation_multiplier == 1:
		return is_on_floor()
	else:
		return is_on_ceiling()

func _flip_orientation():
	orientation_multiplier *= -1

func _animate_squash_stretch(delta):
	# TODO: This doesn't quite work when you "flip" and have a lot of momentum.
	if is_airborne and velocity.y * orientation_multiplier < 0:
		_apply_jump_squash_stretch()
	else:
		# We could make this framerate-independent by using delta properly here, but we don't
		# have to since the delta comes from physics_process.
		# https://www.construct.net/en/blogs/ashleys-blog-2/using-lerp-delta-time-924
		var lerp_val = SQUASH_LERP_SPEED * delta
		assert(lerp_val <= 1.0)
		squash_stretch_scale.x = lerp(squash_stretch_scale.x, 1.0, lerp_val)
		squash_stretch_scale.y = lerp(squash_stretch_scale.y, 1.0, lerp_val)
	$sprite.scale = squash_stretch_scale

func _apply_jump_squash_stretch():
	squash_stretch_scale.x = range_lerp(abs(velocity.y), 0, JUMP_VEL, 1.0, JUMP_SQUASH_STRETCH.x)
	squash_stretch_scale.y = range_lerp(abs(velocity.y), 0, JUMP_VEL, 1.0, JUMP_SQUASH_STRETCH.y)
	$sprite.scale = squash_stretch_scale

func _update_sprite_flip():
	$sprite.flip_h = !facing_right
	$sprite.flip_v = orientation_multiplier != 1
	
func exit_cutscene():
	state = State.CONTROLLABLE;

func enter_cutscene():
	state = State.CUTSCENE;
