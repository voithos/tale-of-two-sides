extends Sprite

export (float) var speed = 1
export (float) var acceleration = 3.0
export (float) var max_size = 3
export (float, 0, 1) var distortion_strength = 0.178
export (float, 0, 1) var mask_contribution = 0

onready var current_scale = Vector2.ZERO
var is_expanding = false
var starting_pos = Vector2.ZERO

func _ready():
    scale = Vector2.ZERO
    material.set_shader_param("distortion_strength", distortion_strength)
    material.set_shader_param("mask_contribution", mask_contribution)

func _process(delta):
    if is_expanding:
        if scale.x < max_size:
            scale += Vector2(speed, speed) * delta
            current_scale *= 1.0 + acceleration * delta
            global_position = starting_pos
        else:
            is_expanding = false
            current_scale = Vector2.ZERO
            hide()

func shockwave(from):
    starting_pos = from
    global_position = starting_pos
    is_expanding = true
    show()
    scale = Vector2.ZERO
    current_scale = Vector2.ZERO
