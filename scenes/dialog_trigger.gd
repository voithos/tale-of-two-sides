extends Node2D


export(String) var dialog = "intro"
export(Vector2) var box_size = Vector2(10,10)

var started = false;
onready var player = $"../player"

func _ready():
    $Area2D/CollisionShape2D.get_shape().set_extents(box_size);

func create_dialog():
    started = true;
    var new_dialog = Dialogic.start(dialog)
    new_dialog.connect("timeline_end", self, "_dialog_end")
    player.enter_cutscene();
    get_parent().add_child(new_dialog)

func _dialog_end(signal_type):
    player.exit_cutscene();

func _on_Area2D_body_entered(body):
    if !started && body.is_in_group("player") && body.state == body.State.CONTROLLABLE:
        create_dialog();
