extends CanvasLayer

signal unfade_complete
signal fade_complete

export (bool) var start_immediately = true

func _ready():
    add_to_group("transition")
    
    if start_immediately:
        $sprite.frame = 16
        begin_unfade()
    else:
        $sprite.frame = 0

# Unfade animation is started immediately.

func begin_unfade():
    $animation.play("unfade")
    yield($animation, "animation_finished")
    $sprite.hide()
    emit_signal("unfade_complete")

func begin_fade():
    $sprite.show()
    $animation.play("fade")
    yield($animation, "animation_finished")
    emit_signal("fade_complete")
