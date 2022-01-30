class_name Player
extends KinematicBody2D

enum State {
    # Player can be controlled.
    CONTROLLABLE,
    # Player is in a non-gameplay "starting level" or "ending level" animation, etc.
    ANIMATING,
    # Player is in a cutscene,
    CUTSCENE,
}

# The current state of the player.
var state = State.CONTROLLABLE
var previous_state = state

# Tracking variables for phase-through mechanic, and vertical and horizontal sprite flipping.
export (bool) var facing_right = true
# Either 1.0 if player is right-side-up, or -1.0 if player is upside down.
var orientation_multiplier = 1
# When this is true, the first contact with a phaseable floor will trigger phasing.
var phase_through_enabled = false

const PHASEABLE_COLLISION_LAYER = int(pow(2, 1))
const PHASEABLE_RAYCAST_LENGTH = 10000 # Length of the raycast to check entry/exit location for phasing.

const TILE_REGION_CAMERA_BOUNDARY_MARGIN := 128.0
const TILE_REGION_FALL_BOUNDARY_MARGIN := \
        TILE_REGION_CAMERA_BOUNDARY_MARGIN * 1.5

var fall_boundary: Rect2

var level_logic

var is_destroyed := false

# Movement state.
var velocity = Vector2.ZERO
var previous_velocity = Vector2.ZERO
var is_moving = false
var is_airborne = false
var was_airborne = false
var is_fast_falling = false

const HORIZONTAL_VEL = 75.0
const HORIZONTAL_ACCEL = 20 # How quickly we accelerate to max speed

const GRAVITY = 6.0
const GRAVITY_DECREASE_THRESHOLD = 10 # The speed below which gravity is decreased.
const GRAVITY_DECREASE_MULTIPLIER = 0.5 # The amount of decrease for low gravity (at the height of a jump).
const JUMP_VEL = 200
const TERM_VEL = JUMP_VEL * 2
const FAST_FALL_MULTIPLIER = 1.7 # How much faster fast fall is compared to gravity
const JUMP_RELEASE_MULTIPLIER = 0.5 # Multiplied by velocity if button released during the initial part of the jump.

# Squash and stretch
var squash_stretch_scale = Vector2.ONE
const JUMP_SQUASH_STRETCH = Vector2(0.8, 1.2)
const LAND_SQUASH_STRETCH = Vector2(1.5, 0.4)
const PHASE_SQUASH_STRETCH = Vector2(0.8, 1.2)
const SQUASH_LERP_SPEED = 10


# Phase Shift Animation state
var phase_destination = Vector2(0,0)
var phase_origin = Vector2(0,0)
var is_phasing_animation = false;
const TEST_PHASE_DIRECTION = Vector2(200,-20)
const PHASE_ANIM_SPEED = 4;
const PHASE_MOVE_SPEED = 400;

func _ready():
    add_to_group("player")
    _update_sprite_flip()
    $animation.play("idle")
    level_logic = _get_level_logic()
    _set_boundaries()

func _physics_process(delta):
    if is_destroyed:
        return
    
    if state == State.ANIMATING && is_phasing_animation:
        _handle_phase_animation(delta);

    if state != State.CONTROLLABLE:
        return
        
    $phase_particles.emitting = phase_through_enabled;
    
    if !fall_boundary.has_point(position):
        _on_fall_out_of_bounds()
        return
    
    if Input.is_action_just_pressed("phase"):
        _begin_phasing()
    
    if Input.is_action_just_pressed("debug_anim"):
        pass
#		_test_phase_anim()

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

    previous_velocity = velocity
    velocity = move_and_slide(velocity, Vector2.UP)
    
    if was_airborne and _is_on_surface():
        _landed()
    elif !was_airborne and !_is_on_surface():
        # Fell off a cliff.
        is_airborne = true

    if !is_airborne:
        if is_moving:
            $animation.play("run")
        else:
            $animation.play("idle")

func _jump():
    is_airborne = true
    is_fast_falling = false
    velocity.y = -JUMP_VEL * orientation_multiplier
    $animation.play("jump")
    _apply_jump_squash_stretch()
    sfx.play(sfx.JUMP)

func _landed():
    is_airborne = false
    var did_phase = false
    # TODO: Only phase through certain materials?
    if phase_through_enabled:
        # Have to use previous velocity, because this is post-collision (so velocity would be 0).
        did_phase = _check_phase_through(previous_velocity.normalized())
        if did_phase:
            # Since we phased through, we should retain the velocity we had before the surface collision.
            velocity = previous_velocity
            is_airborne = true
    
    # Only play the sfx if we didn't phase.
    if !did_phase:
        sfx.play(sfx.LAND, sfx.QUIET_DB)

func _is_on_surface():
    if orientation_multiplier == 1:
        return is_on_floor()
    else:
        return is_on_ceiling()

func _begin_phasing():
    phase_through_enabled = true
    # Check immediately in case we're already on the ground.
    if _is_on_surface():
        _check_phase_through(Vector2.DOWN * orientation_multiplier)

func _check_phase_through(direction: Vector2) -> bool:
    var is_colliding_with_phaseable = false
    for i in get_slide_count():
        var collision = get_slide_collision(i)
        if collision.collider.get_collision_layer() & PHASEABLE_COLLISION_LAYER:
            is_colliding_with_phaseable = true

    if is_colliding_with_phaseable:
        # We know that we're near a phaseable surface, so we resort to manually querying the space state.
        var ray = direction * PHASEABLE_RAYCAST_LENGTH
        var from = $raycast.global_position
        var to = from + ray
        var results = _double_raycast(_get_space_state(), from, to, PHASEABLE_COLLISION_LAYER)
        var entered = results[0]
        var exited = results[1]
        
        if !entered.empty() and !exited.empty():
            # Since we're flipping orientation, calculate the offset between the exit point (of the
            # raycast) and the position we'll need to set the player at.
            var opposite_position_offset = $raycast.global_position - global_position
            # We multiply the opposite_position_offset by a slight extra amount so that we aren't
            # touching the other surface. Otherwise, move_and_slide seems to just randomly "snap"
            # and sets the velocity to 0 on the next frame.
            
            # trigger phase animation
            var origin = global_position;
            var destination = exited[exited.size() - 1]["position"] + 1.3 * opposite_position_offset
            _initiate_phase_anim(origin, destination)
            _flip_orientation()
        
        phase_through_enabled = false
        return true

    # Disable, since we didn't end up finding a phase through.
    phase_through_enabled = false
    return false

func _get_space_state():
    var space_rid = get_world_2d().space
    var space_state = Physics2DServer.space_get_direct_state(space_rid)
    return space_state

# Similar to Physics2DDirectSpaceState.intersect_ray.
const RAY_EPSILON = 0.001
func _double_raycast(space_state: Physics2DDirectSpaceState, from, to, collision_layer=2147483647, exclude_self=true, collide_with_bodies=true, collide_with_areas=true):
    var dir = (to - from).normalized()
    var rev_dir = (from - to).normalized()

    var exclude = [self] if exclude_self else []
    
    var entered = []
    var exited = []
    
    # Get forward collisions along the ray.
    var result = space_state.intersect_ray(from, to, exclude, collision_layer, collide_with_bodies, collide_with_areas)
    # Keep track of the last collider and ignore re-collisions with the same collider. Godot should
    # take care of this, but it's unfortunately broken for tilemaps due to https://github.com/godotengine/godot/issues/17090.
    var last_collider = null
    while !result.empty():
        if result["collider"] != last_collider:
            entered.push_back(result)
        last_collider = result["collider"]
        result = space_state.intersect_ray(result["position"] + RAY_EPSILON * dir, to, exclude + [result["collider"]], collision_layer, collide_with_bodies, collide_with_areas)
    
    # Get backward collisions along the ray.
    result = space_state.intersect_ray(to, from, exclude, collision_layer, collide_with_bodies, collide_with_areas)
    last_collider = null
    while !result.empty():
        if result["collider"] != last_collider:
            exited.push_back(result)
        last_collider = result["collider"]
        result = space_state.intersect_ray(result["position"] + RAY_EPSILON * rev_dir, from, exclude + [result["collider"]], collision_layer, collide_with_bodies, collide_with_areas)
    
    return [entered, exited]

func _set_boundaries() -> void:
    var tile_map_region: Rect2 = level_logic.get_combined_tile_map_region()
    var player_half_size := calculate_half_width_height($shape.shape, false)
    
    var camera_boundary := \
            tile_map_region.grow(TILE_REGION_CAMERA_BOUNDARY_MARGIN)
    fall_boundary = tile_map_region \
            .grow(TILE_REGION_FALL_BOUNDARY_MARGIN) \
            .grow_individual(
                -player_half_size.x,
                -player_half_size.y,
                -player_half_size.x,
                -player_half_size.y)
    
    $player_camera.limit_left = camera_boundary.position.x
    $player_camera.limit_top = camera_boundary.position.y
    $player_camera.limit_right = camera_boundary.end.x
    $player_camera.limit_bottom = camera_boundary.end.y

static func calculate_half_width_height(
        shape: Shape2D,
        is_rotated_90_degrees: bool) -> Vector2:
    var half_width_height: Vector2
    if shape is CircleShape2D:
        half_width_height = Vector2(
                shape.radius,
                shape.radius)
    elif shape is CapsuleShape2D:
        half_width_height = Vector2(
                shape.radius,
                shape.radius + shape.height / 2.0)
    elif shape is RectangleShape2D:
        half_width_height = shape.extents
    else:
        push_error(
                ("Invalid Shape2D provided to calculate_half_width_height: " +
                "%s. The upported shapes are: CircleShape2D, " +
                "CapsuleShape2D, RectangleShape2D.") % str(shape))
    
    if is_rotated_90_degrees:
        var swap := half_width_height.x
        half_width_height.x = half_width_height.y
        half_width_height.y = swap
        
    return half_width_height

func _get_level_logic():
    var all_level_logics := get_tree().get_nodes_in_group("level")
    var level_logics_in_level := []
    for level_logic in all_level_logics:
        var parent = get_parent()
        # Loop to try to find a common ancestor with the current LevelLogic.
        while is_instance_valid(parent) and \
                not parent is Control:
            if parent.is_a_parent_of(level_logic):
                level_logics_in_level.push_back(level_logic)
                break
            parent = parent.get_parent()
    assert(level_logics_in_level.size() == 1)
    return level_logics_in_level[0]

func _flip_orientation():
    orientation_multiplier *= -1
    $sprite.flip_v = orientation_multiplier != 1
    $raycast.cast_to *= -1
    $raycast.position *= -1
    $shape.position *= -1

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

func _initiate_phase_anim(origin, destination):
    phase_origin = origin
    phase_destination = destination
    state = State.ANIMATING;
    is_phasing_animation = true;
    $phase_sprite.visible = true;
    $phase_particles.emitting = true;

func _handle_phase_animation(delta):
    # Used to transition into and out of block. Transition distance is quarter of the total phase distance
    var quarter_distance = (phase_destination - phase_origin).length()/4.0
    var phase_pos = min(min(global_position.distance_to(phase_origin), global_position.distance_to(phase_destination)), quarter_distance)
    var speed_modulation = range_lerp(phase_pos, 0, quarter_distance, 1.0, 0.75);
    
    # Phase movement. Slows down inside block and speeds up as you exit.
    global_position += (phase_destination - phase_origin).normalized()*PHASE_MOVE_SPEED*delta*speed_modulation
    
    # Shift between player sprite and phase sprite
    $sprite.modulate.a = range_lerp(phase_pos, 0, quarter_distance, 1.0, 0);
    $phase_sprite.modulate.a = range_lerp(phase_pos, 0, quarter_distance, 0, 1.0);
    
    squash_stretch_scale.x = range_lerp(phase_pos, 0, quarter_distance, 1.0, PHASE_SQUASH_STRETCH.x)
    squash_stretch_scale.y = range_lerp(phase_pos, 0, quarter_distance, 1.0, PHASE_SQUASH_STRETCH.y)
    $phase_sprite.scale = squash_stretch_scale
    $phase_sprite.rotation = Vector2(0,1).angle_to((phase_destination-phase_origin).normalized())
    
    # Stretch phase sprite in direction of shift.
    
    # TODO: stretch sprites in direction of shift.
    if phase_origin.distance_to(global_position) > phase_origin.distance_to(phase_destination):
        is_phasing_animation = false;
        state = State.CONTROLLABLE;
        $phase_sprite.visible = false;
        $phase_particles.emitting = false
        # TODO: Apply exit speed


func _apply_jump_squash_stretch():
    squash_stretch_scale.x = range_lerp(abs(velocity.y), 0, JUMP_VEL, 1.0, JUMP_SQUASH_STRETCH.x)
    squash_stretch_scale.y = range_lerp(abs(velocity.y), 0, JUMP_VEL, 1.0, JUMP_SQUASH_STRETCH.y)
    $sprite.scale = squash_stretch_scale

func _update_sprite_flip():
    $sprite.flip_h = !facing_right

func exit_cutscene():
    state = State.CONTROLLABLE;

func enter_cutscene():
    state = State.CUTSCENE;

func on_touched_crystal(crystal: Crystal) -> void:
    crystal.queue_free()
    sfx.play(sfx.CADENCE_SUCCESS)
    screen.on_level_complete()

func _on_fall_out_of_bounds() -> void:
    sfx.play(sfx.CADENCE_FAILURE)
    level_logic.reset()
    queue_free()
    is_destroyed = true
